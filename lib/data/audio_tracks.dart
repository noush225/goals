import 'package:flutter/foundation.dart';

/// Pistes ambiantes disponibles dans Momentum.
///
/// `id` est stable et persisté en base ; `assetPath` peut changer si tu
/// renommes le fichier sans casser les anciennes tâches.
@immutable
class AmbientTrack {
  const AmbientTrack({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.description,
  });

  final String id;
  final String label;
  final String assetPath; // relatif à `assets/` (AssetSource s'en charge)
  final String description;
}

/// Catalogue. Ajouter des entrées ici suffit pour les voir apparaître dans
/// la sheet d'édition + le Focus Mode.
class AudioTracks {
  AudioTracks._();

  static const List<AmbientTrack> all = <AmbientTrack>[
    AmbientTrack(
      id: 'forest_rain',
      label: 'Pluie en forêt',
      assetPath: 'audio/drawingsample1.mp3',
      description: 'Pluie douce, feuillage, atmosphère apaisante',
    ),
    AmbientTrack(
      id: 'paper_pencil',
      label: 'Crayon sur papier',
      assetPath: 'audio/drawingsample2.mp3',
      description: 'Bruit du dessin, texture artisanale',
    ),
  ];

  static AmbientTrack get defaultTrack => all.first;

  static AmbientTrack? byId(String? id) {
    if (id == null) return null;
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Retourne la piste demandée si elle existe encore, sinon la piste par défaut.
  static AmbientTrack resolve(String? id) => byId(id) ?? defaultTrack;
}
