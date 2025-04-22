class Course {
  final String imageUrl;
  final String name;
  final int time;
  final String students;

  Course({
    required this.imageUrl,
    required this.name,
    required this.time,
    required this.students,
  });
}

final List<Course> courseList = [
  Course(
    imageUrl: 'lib/images/course5.jpg',
    name: 'Cardio Exercises',
    time: 20,
    students: 'Beginner',
  ),
  Course(
    imageUrl: 'lib/images/course4.jpg',
    name: 'Exercises',
    time: 20,
    students: 'Beginner',
  ),
  Course(
    imageUrl: 'lib/images/course3.jpg',
    name: 'Meditation',
    time: 20,
    students: 'Beginner',
  ),
  Course(
    imageUrl: 'lib/images/course2.jpg',
    name: 'Daily Yoga',
    time: 30,
    students: 'Intermediate',
  ),
  Course(
    imageUrl: 'lib/images/course1.jpg',
    name: 'Advance Stretching',
    time: 45,
    students: 'Advanced',
  ),
];