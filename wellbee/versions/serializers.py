from rest_framework import serializers

from versions.models import Version

class VersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Version
        fields = ('version','created_date')