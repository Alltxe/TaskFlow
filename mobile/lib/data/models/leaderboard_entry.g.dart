// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardEntryImpl(
      user: LeaderboardUser.fromJson(json['user'] as Map<String, dynamic>),
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
    );

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
        _$LeaderboardEntryImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'pointsEarned': instance.pointsEarned,
      'rank': instance.rank,
    };

_$LeaderboardUserImpl _$$LeaderboardUserImplFromJson(
        Map<String, dynamic> json) =>
    _$LeaderboardUserImpl(
      id: json['id'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$$LeaderboardUserImplToJson(
        _$LeaderboardUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
    };
