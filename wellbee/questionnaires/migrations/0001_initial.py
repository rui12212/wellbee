# Generated by Django 4.2.14 on 2024-10-01 17:53

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('attendances', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Question',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('question', models.IntegerField(choices=[(0, 'Been feeling bad and in bad health?'), (1, 'Been feeling in need of a good tonic?'), (2, 'Been feeling run down and out of sorts?'), (3, 'Been feeling that you are ill?'), (4, 'Been getting any pains in your head?'), (5, 'Been getting a feeling of tightness or pressure in your head?'), (6, 'Been having hot or cold spells?'), (7, 'Been losing much sleep over worry?'), (8, 'Been having difficulty in staying asleep once you fall asleep?'), (9, 'Been feeling constantly under strain?'), (10, 'Been getting edgy or bad tempered?'), (11, 'Been getting scared or panicky for no reason?'), (12, 'Been feeling everything is getting on top of you?'), (13, 'Been feeling nervous and strung-out all the time?'), (14, 'Been managing to keep yourself busy and occupied?'), (15, 'Been taking longer over the things you do?'), (16, 'Been feeling on the whole that you were doing things well?'), (17, 'Been satisfied with the way you have carried out your tasks?'), (18, 'Been feeling that you are playing a useful part in things?'), (19, 'Been feeling capable of making decisions about things?'), (20, 'Been able to enjoy your normal day-to-day activities?'), (21, 'Been thinking of yourself as a worthless person?'), (22, 'Been feeling that life is entirely hopeless?'), (23, 'Been feeling that life is not worth living?'), (24, 'Been thinking of the possibility that you may do away with yourself?'), (25, 'Been feeling at times that you could not do anything because your nerves were too bad?'), (26, 'Been finding yourself wishing you were dead and away from it all?'), (27, 'Been finding that the idea of taking your own life keeps coming into your mind?')], verbose_name='question')),
                ('order', models.IntegerField()),
                ('type', models.IntegerField(blank=True, choices=[(0, 'Somatic symptoms'), (1, 'Anxiety and insomnia'), (2, 'Social dysfunction'), (3, 'Severe depression')], null=True, verbose_name='type')),
            ],
        ),
        migrations.CreateModel(
            name='SurveyResponse',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('response0', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response0')),
                ('score0', models.IntegerField(blank=True, null=True, verbose_name='score0')),
                ('response1', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response1')),
                ('score1', models.IntegerField(blank=True, null=True, verbose_name='score1')),
                ('response2', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response2')),
                ('score2', models.IntegerField(blank=True, null=True, verbose_name='score2')),
                ('response3', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response3')),
                ('score3', models.IntegerField(blank=True, null=True, verbose_name='score3')),
                ('response4', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response4')),
                ('score4', models.IntegerField(blank=True, null=True, verbose_name='score4')),
                ('response5', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response5')),
                ('score5', models.IntegerField(blank=True, null=True, verbose_name='score5')),
                ('response6', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response6')),
                ('score6', models.IntegerField(blank=True, null=True, verbose_name='score6')),
                ('response7', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response7')),
                ('score7', models.IntegerField(blank=True, null=True, verbose_name='score7')),
                ('response8', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response8')),
                ('score8', models.IntegerField(blank=True, null=True, verbose_name='score8')),
                ('response9', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response9')),
                ('score9', models.IntegerField(blank=True, null=True, verbose_name='score9')),
                ('response10', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response10')),
                ('score10', models.IntegerField(blank=True, null=True, verbose_name='score10')),
                ('response11', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response11')),
                ('score11', models.IntegerField(blank=True, null=True, verbose_name='score11')),
                ('response12', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response12')),
                ('score12', models.IntegerField(blank=True, null=True, verbose_name='score12')),
                ('response13', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response13')),
                ('score13', models.IntegerField(blank=True, null=True, verbose_name='score13')),
                ('response14', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response14')),
                ('score14', models.IntegerField(blank=True, null=True, verbose_name='score14')),
                ('response15', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response15')),
                ('score15', models.IntegerField(blank=True, null=True, verbose_name='score15')),
                ('response16', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response16')),
                ('score16', models.IntegerField(blank=True, null=True, verbose_name='score16')),
                ('response17', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response17')),
                ('score17', models.IntegerField(blank=True, null=True, verbose_name='score17')),
                ('response18', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response18')),
                ('score18', models.IntegerField(blank=True, null=True, verbose_name='score18')),
                ('response19', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response19')),
                ('score19', models.IntegerField(blank=True, null=True, verbose_name='score19')),
                ('response20', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response20')),
                ('score20', models.IntegerField(blank=True, null=True, verbose_name='score20')),
                ('response21', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response21')),
                ('score21', models.IntegerField(blank=True, null=True, verbose_name='score21')),
                ('response22', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response22')),
                ('score22', models.IntegerField(blank=True, null=True, verbose_name='score22')),
                ('response23', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response23')),
                ('score23', models.IntegerField(blank=True, null=True, verbose_name='score23')),
                ('response24', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response24')),
                ('score24', models.IntegerField(blank=True, null=True, verbose_name='score24')),
                ('response25', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response25')),
                ('score25', models.IntegerField(blank=True, null=True, verbose_name='score25')),
                ('response26', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response26')),
                ('score26', models.IntegerField(blank=True, null=True, verbose_name='score26')),
                ('response27', models.IntegerField(choices=[(0, 'Better than usual'), (1, 'Same as usual'), (2, 'Worse than usual'), (3, 'Much worse than usual')], verbose_name='response27')),
                ('score27', models.IntegerField(blank=True, null=True, verbose_name='score27')),
                ('total_score', models.IntegerField(default=0)),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('attendee', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='attendances.attendee', verbose_name='attendee')),
            ],
        ),
        migrations.CreateModel(
            name='BaseBodySurvey',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('height', models.DecimalField(decimal_places=1, max_digits=4, verbose_name='height')),
                ('weight', models.DecimalField(decimal_places=1, max_digits=4, verbose_name='weight')),
                ('BMI', models.DecimalField(decimal_places=1, default=0.0, max_digits=4, null=True, verbose_name='BMI')),
                ('created_at', models.DateTimeField(auto_now_add=True, null=True)),
                ('attendee', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='attendances.attendee', verbose_name='attendee')),
            ],
        ),
    ]
