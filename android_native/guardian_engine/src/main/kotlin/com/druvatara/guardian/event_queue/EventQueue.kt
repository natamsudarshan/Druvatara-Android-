package com.druvatara.guardian.event_queue

import android.content.Context
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentLinkedQueue
import java.util.concurrent.atomic.AtomicBoolean

class EventQueue(private val context: Context, private val scope: CoroutineScope) {
    private val TAG = "EventQueue"
    private val eventQueue = ConcurrentLinkedQueue<DeviceEvent>()
    private val isProcessing = AtomicBoolean(false)
    private var eventProcessor: EventProcessor? = null

    data class DeviceEvent(
        val eventId: String,
        val eventType: String,
        val eventVersion: Int = 1,
        val capturedAt: Long,
        val payload: Map<String, Any>,
        val signature: String? = null,
    )

    fun enqueueEvent(event: DeviceEvent) {
        eventQueue.add(event)
        Log.d(TAG, "Event enqueued: ${event.eventType} (queue size: ${eventQueue.size})")
    }

    fun enqueueEvent(
        eventType: String,
        payload: Map<String, Any>,
        eventId: String = java.util.UUID.randomUUID().toString(),
        eventVersion: Int = 1,
    ) {
        val event = DeviceEvent(
            eventId = eventId,
            eventType = eventType,
            eventVersion = eventVersion,
            capturedAt = System.currentTimeMillis(),
            payload = payload,
        )
        enqueueEvent(event)
    }

    fun startProcessing(processor: EventProcessor) {
        eventProcessor = processor
        if (isProcessing.compareAndSet(false, true)) {
            processQueue()
        }
    }

    private fun processQueue() {
        scope.launch(Dispatchers.IO) {
            while (isProcessing.get() && !eventQueue.isEmpty()) {
                val event = eventQueue.poll()
                event?.let {
                    try {
                        eventProcessor?.processEvent(it)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing event: ${it.eventType}", e)
                        // Re-queue for retry
                        eventQueue.add(it)
                    }
                }
                try {
                    kotlinx.coroutines.delay(100) // Small delay between events
                } catch (e: InterruptedException) {
                    break
                }
            }
            isProcessing.set(false)
        }
    }

    fun stopProcessing() {
        isProcessing.set(false)
    }

    fun getQueueSize(): Int = eventQueue.size

    fun getPendingEvents(): List<DeviceEvent> {
        return eventQueue.toArray().map { it as DeviceEvent }
    }

    interface EventProcessor {
        fun processEvent(event: DeviceEvent)
    }
}