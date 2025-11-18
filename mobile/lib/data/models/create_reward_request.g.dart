// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_reward_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateRewardRequestImpl _$$CreateRewardRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateRewardRequestImpl(
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      cost: (json['cost'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$CreateRewardRequestImplToJson(
        _$CreateRewardRequestImpl instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'name': instance.name,
      'description': instance.description,
      'cost': instance.cost,
      'imageUrl': instance.imageUrl,
    };
