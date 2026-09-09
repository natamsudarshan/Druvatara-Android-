import { UserRole } from "@prisma/client";

export const ADMIN_ROLES: UserRole[] = ["ADMIN", "SUPPORT"];
export const PARENT_ROLES: UserRole[] = [
  "PARENT",
  "CO_PARENT",
  "GUARDIAN_VIEWER",
];

export function isAdminRole(role: UserRole): boolean {
  return ADMIN_ROLES.includes(role);
}

export function isParentRole(role: UserRole): boolean {
  return PARENT_ROLES.includes(role);
}
