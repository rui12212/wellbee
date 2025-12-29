const String fallbackAssetPath =
    'lib/assets/invi_course_pic/female_fitness.png'; // asset_image_path が空の場合のデフォルト

class CourseImageOption {
  final String label;
  final String path;
  const CourseImageOption(this.label, this.path);
}

const List<CourseImageOption> imageOptions = [
  CourseImageOption('Yoga', 'lib/assets/invi_course_pic/invi_yoga.png'),
  CourseImageOption('Music', 'lib/assets/invi_course_pic/invi_music.png'),
  CourseImageOption('Karate', 'lib/assets/invi_course_pic/invi_karate.png'),
  CourseImageOption('Dance', 'lib/assets/invi_course_pic/invi_dance.png'),
  CourseImageOption(
      'Family Pilates', 'lib/assets/invi_course_pic/invi_family_pilates.png'),
  CourseImageOption(
      'Family Pilates', 'lib/assets/invi_course_pic/invi_family_yoga.png'),
  CourseImageOption('Music', 'lib/assets/invi_course_pic/invi_music.png'),
  CourseImageOption('Pilates', 'lib/assets/invi_course_pic/invi_pilates.png'),
  CourseImageOption(
      'Male Fitness', 'lib/assets/invi_course_pic/male_fitness.png'),
  CourseImageOption(
      'Private Yoga', 'lib/assets/invi_course_pic/private_yoga.png'),
  CourseImageOption(
      'Private Pilates', 'lib/assets/invi_course_pic/private_pilates.png'),
  CourseImageOption('Wellbee Gold', 'lib/assets/invi_course_pic/invi_gold.png'),
  CourseImageOption('Flamenco', 'lib/assets/invi_course_pic/invi_flamenco.png'),
  CourseImageOption('Toning', 'lib/assets/invi_course_pic/invi_toning.png'),
  CourseImageOption('Zumba', 'lib/assets/invi_course_pic/invi_zumba.png'),
  CourseImageOption('Fallback', fallbackAssetPath),
];
