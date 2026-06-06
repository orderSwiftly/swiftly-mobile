// models/landmark.dart

class Landmark {
  final String landmark_id;
  final String landmark_name;
  final String landmark_zone_id;
  final String landmark_zone_name;

  Landmark({
    required this.landmark_id,
    required this.landmark_name,
    required this.landmark_zone_id,
    required this.landmark_zone_name,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      landmark_id: json['landmark_id'],
      landmark_name: json['landmark_name'],
      landmark_zone_id: json['landmark_zone_id'],
      landmark_zone_name: json['landmark_zone_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'landmark_id': landmark_id,
      'landmark_name': landmark_name,
      'landmark_zone_id': landmark_zone_id,
      'landmark_zone_name': landmark_zone_name,
    };
  }
}

class ListLandmarksResponse {
  final List<Landmark> landmarks;
  final List<dynamic> recent_landmarks;

  ListLandmarksResponse({
    required this.landmarks,
    required this.recent_landmarks,
  });

  factory ListLandmarksResponse.fromJson(Map<String, dynamic> json) {
    return ListLandmarksResponse(
      landmarks: (json['landmarks'] as List)
          .map((landmark) => Landmark.fromJson(landmark))
          .toList(),
      recent_landmarks: json['recent_landmarks'] ?? [],
    );
  }
}
