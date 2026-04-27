from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('attendances', '0016_remove_course_asset_image_path'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='membership',
            name='offer',
        ),
        migrations.AddField(
            model_name='membership',
            name='currency',
            field=models.CharField(
                choices=[('USD', 'USD'), ('IQD', 'IQD')],
                default='USD',
                max_length=3,
                verbose_name='currency',
            ),
        ),
    ]
