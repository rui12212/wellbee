from rest_framework import serializers
from django.contrib.auth import get_user_model
from questionnaires.models import BaseBodySurvey, Question, SurveyResponse


class BaseBodySurveySerializer(serializers.ModelSerializer):
    class Meta:
        model = BaseBodySurvey
        fields=('attendee', 'height', 'weight', 'BMI','created_at')
        extra_kwargs= {'attendee': {'read_only': True}}
        
    def create(self, validated_data):
        validated_data['BMI'] = validated_data['weight'] / ((validated_data['height'] / 100) ** 2)
        return super().create(validated_data)
    


class SurveyResponseSerializer(serializers.ModelSerializer):
    class Meta:
        model = SurveyResponse
        fields = (
            'attendee',
            'response0', 'score0',
            'response1', 'score1',
            'response2', 'score2',
            'response3', 'score3',
            'response4', 'score4',
            'response5', 'score5',
            'response6', 'score6',
            'response7', 'score7',
            'response8', 'score8',
            'response9', 'score9',
            'response10', 'score10',
            'response11', 'score11',
            'response12', 'score12',
            'response13', 'score13',
            'response14', 'score14',
            'response15', 'score15',
            'response16', 'score16',
            'response17', 'score17',
            'response18', 'score18',
            'response19', 'score19',
            'response20', 'score20',
            'response21', 'score21',
            'response22', 'score22',
            'response23', 'score23',
            'response24', 'score24',
            'response25', 'score25',
            'response26', 'score26',
            'response27', 'score27',
            'total_score',
            'created_at',
        )
        extra_kwargs = {'attendee': {'read_only': True}, 'created_at': {'read_only': True}}

    # def create(self, validated_data):
    #     # 例: total_score を計算する
    #     validated_data['total_score'] = sum(
    #         validated_data.get(f'score{i}', 0) for i in range(28)
    #     )
    #     return super().create(validated_data)

    
class QuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Question
        fields=('question', 'order', 'type',)
        # extra_kwargs= {'attendee': {'read_only': True}}
    