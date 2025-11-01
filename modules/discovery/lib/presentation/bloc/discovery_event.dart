// lib/presentation/bloc/discovery_event.dart

part of 'discovery_bloc.dart';

@immutable
abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Khi Home screen (hoặc ai đó) muốn load dữ liệu trending/latest,
/// gọi DiscoveryLoadEvent().
class DiscoveryLoadEvent extends DiscoveryEvent {
  const DiscoveryLoadEvent();
}
