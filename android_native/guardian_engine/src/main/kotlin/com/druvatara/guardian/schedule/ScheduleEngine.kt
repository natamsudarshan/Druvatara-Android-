package com.druvatara.guardian.schedule

import android.content.Context
import android.util.Log
import com.druvatara.guardian.policy.Schedule
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Calendar
import java.util.TimeZone

class ScheduleEngine(private val context: Context) {
    private val TAG = "ScheduleEngine"
    private var schedules = mutableListOf<Schedule>()
    private var isRunning = false

    suspend fun startSchedules() = withContext(Dispatchers.IO) {
        isRunning = true
        monitorSchedules()
    }

    fun applySchedules(newSchedules: List<Schedule>) {
        schedules = newSchedules.filter { it.isActive }.toMutableList()
    }

    fun getActiveSchedule(): Schedule? {
        val now = System.currentTimeMillis()
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = now

        val currentDay = calendar[Calendar.DAY_OF_WEEK] // 1=Sunday, 7=Saturday
        val adjustedDay = if (currentDay == 1) 7 else currentDay - 1 // Convert to 1=Monday, 7=Sunday

        val currentMinutes = calendar[Calendar.HOUR_OF_DAY] * 60 + calendar[Calendar.MINUTE]

        return schedules.firstOrNull { schedule ->
            adjustedDay in schedule.days &&
            isTimeInRange(currentMinutes, schedule.startTime, schedule.endTime)
        }
    }

    private fun isTimeInRange(currentMinutes: Int, startTime: String, endTime: String): Boolean {
        val startMinutes = parseTimeToMinutes(startTime)
        val endMinutes = parseTimeToMinutes(endTime)

        if (startMinutes <= endMinutes) {
            return currentMinutes >= startMinutes && currentMinutes < endMinutes
        } else {
            // Overnight schedule (e.g., 22:00 - 07:00)
            return currentMinutes >= startMinutes || currentMinutes < endMinutes
        }
    }

    private fun parseTimeToMinutes(time: String): Int {
        val parts = time.split(":")
        return if (parts.size == 2) {
            parts[0].toInt() * 60 + parts[1].toInt()
        } else 0
    }

    fun isInRestrictedSchedule(): Boolean {
        return getActiveSchedule() != null
    }

    fun getNextScheduleChange(): Long? {
        val now = System.currentTimeMillis()
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = now

        var nextChange: Long? = null

        schedules.forEach { schedule ->
            val today = calendar[Calendar.DAY_OF_WEEK]
            val adjustedToday = if (today == 1) 7 else today - 1

            // Check start time
            val startMinutes = parseTimeToMinutes(schedule.startTime)
            val startCalendar = Calendar.getInstance().apply {
                timeInMillis = now
                set(Calendar.HOUR_OF_DAY, startMinutes / 60)
                set(Calendar.MINUTE, startMinutes % 60)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            if (adjustedToday in schedule.days && startCalendar.timeInMillis > now) {
                nextChange = minOf(nextChange ?: Long.MAX_VALUE, startCalendar.timeInMillis)
            } else {
                // Find next day this schedule is active
                for (i in 1..7) {
                    val checkDay = (adjustedToday + i - 1) % 7 + 1
                    if (checkDay in schedule.days) {
                        val nextCal = Calendar.getInstance().apply {
                            timeInMillis = now
                            add(Calendar.DAY_OF_YEAR, i)
                            set(Calendar.HOUR_OF_DAY, startMinutes / 60)
                            set(Calendar.MINUTE, startMinutes % 60)
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                        }
                        nextChange = minOf(nextChange ?: Long.MAX_VALUE, nextCal.timeInMillis)
                        break
                    }
                }
            }

            // Check end time
            val endMinutes = parseTimeToMinutes(schedule.endTime)
            val endCalendar = Calendar.getInstance().apply {
                timeInMillis = now
                set(Calendar.HOUR_OF_DAY, endMinutes / 60)
                set(Calendar.MINUTE, endMinutes % 60)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            if (adjustedToday in schedule.days && endCalendar.timeInMillis > now) {
                nextChange = minOf(nextChange ?: Long.MAX_VALUE, endCalendar.timeInMillis)
            }
        }

        return nextChange
    }

    private fun monitorSchedules() {
        while (isRunning) {
            try {
                val activeSchedule = getActiveSchedule()
                if (activeSchedule != null) {
                    Log.d(TAG, "Active schedule: ${activeSchedule.name}")
                    // Apply restrictions for non-allowed apps
                }
                Thread.sleep(60 * 1000) // Check every minute
            } catch (e: Exception) {
                Log.e(TAG, "Error monitoring schedules", e)
            }
        }
    }

    fun stopSchedules() {
        isRunning = false
    }

    fun updateSchedules() {
        // Schedules are applied via applySchedules
    }
}