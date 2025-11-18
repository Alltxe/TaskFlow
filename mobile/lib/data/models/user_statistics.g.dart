// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatisticsImpl _$$UserStatisticsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatisticsImpl(
      userId: json['userId'] as String,
      currentPointBalance: (json['currentPointBalance'] as num).toInt(),
      totalPointsEarned: (json['totalPointsEarned'] as num).toInt(),
      totalPointsSpent: (json['totalPointsSpent'] as num).toInt(),
      tasksCompleted: (json['tasksCompleted'] as num).toInt(),
      tasksAssigned: (json['tasksAssigned'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      tasksCompletedOnTime: (json['tasksCompletedOnTime'] as num).toInt(),
      onTimePercentage: (json['onTimePercentage'] as num).toDouble(),
      leaderboardPosition: (json['leaderboardPosition'] as num?)?.toInt(),
      groupId: json['groupId'] as String?,
    );

Map<String, dynamic> _$$UserStatisticsImplToJson(
        _$UserStatisticsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'currentPointBalance': instance.currentPointBalance,
      'totalPointsEarned': instance.totalPointsEarned,
      'totalPointsSpent': instance.totalPointsSpent,
      'tasksCompleted': instance.tasksCompleted,
      'tasksAssigned': instance.tasksAssigned,
      'completionRate': instance.completionRate,
      'tasksCompletedOnTime': instance.tasksCompletedOnTime,
      'onTimePercentage': instance.onTimePercentage,
      'leaderboardPosition': instance.leaderboardPosition,
      'groupId': instance.groupId,
    };
