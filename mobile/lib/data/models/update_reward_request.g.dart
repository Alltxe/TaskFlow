// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_reward_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateRewardRequestImpl _$$UpdateRewardRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateRewardRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      cost: (json['cost'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$UpdateRewardRequestImplToJson(
        _$UpdateRewardRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'cost': instance.cost,
      'isActive': instance.isActive,
      'imageUrl': instance.imageUrl,
    };
