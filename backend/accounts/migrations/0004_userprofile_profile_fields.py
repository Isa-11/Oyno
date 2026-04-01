from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0003_merge_0002_userprofile_fcm_token_0002_usersettings'),
    ]

    operations = [
        migrations.AddField(
            model_name='userprofile',
            name='avatar_data',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='city',
            field=models.CharField(blank=True, default='', max_length=80),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='rating',
            field=models.FloatField(default=0.0),
        ),
    ]
