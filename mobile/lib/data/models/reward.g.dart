// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardImpl _$$RewardImplFromJson(Map<String, dynamic> json) => _$RewardImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      cost: (json['cost'] as num).toInt(),
      isActive: json['isActive'] as bool,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      groupId: json['groupId'] as String,
      createdById: json['createdById'] as String,
    );

Map<String, dynamic> _$$RewardImplToJson(_$RewardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cost': instance.cost,
      'isActive': instance.isActive,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'groupId': instance.groupId,
      'createdById': instance.createdById,
    };
