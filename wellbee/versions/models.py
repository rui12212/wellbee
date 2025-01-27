from django.db import models

class Version(models.Model):
    version = models.FloatField(verbose_name='version',blank=False, null=False, default=0.0)
    created_date = models.DateTimeField(verbose_name='created_date',auto_now_add=True,null=False, blank=False)

    def __str__(self):
        return f"version-{self.version}/{self.created_date}"