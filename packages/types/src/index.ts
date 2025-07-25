// Shared types exports
import { z } from 'zod';

// User types
export const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string(),
  role: z.enum(['student', 'teacher', 'admin']),
  createdAt: z.date(),
  updatedAt: z.date(),
});

export type User = z.infer<typeof UserSchema>;

// Course types
export const CourseSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  teacherId: z.string(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

export type Course = z.infer<typeof CourseSchema>;

// Export placeholder for future types
export default {};
