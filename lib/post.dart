String Url = "http://192.168.0.200:3000";
// String Url = "https://c045-106-184-155-122.ngrok-free.app";

class Post {
  final int createdAt;
  final String posterName;
  final String posterImageUrl;
  final String posterId;
  final String text;
  final String imageName;
  final int postId;

  Post({
    required this.createdAt,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.text,
    required this.imageName,
    required this.postId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      createdAt: json['createdAt'] ,
      posterName: json['posterName'],
      posterImageUrl: json['posterImageUrl'],
      posterId: json['posterId'],
      text: json['text'],
      imageName: json['imageName'],
      postId: json['postId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'posterName': posterName,
      'posterImageUrl': posterImageUrl,
      'posterId': posterId,
      'text': text,
      'imageName': imageName,
      'postId': postId,
    };
  }
}

class Like {
  final String user_id;
  final int postId;
  final int likedAt;

  Like({
    required this.user_id,
    required this.postId,
    required this.likedAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      user_id: json['user_id'],
      postId: json['postId'],
      likedAt: json['likedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'postId': postId,
      'likedAt': likedAt,
    };
  }
}

class Follow {
  final String follower_id;
  final String followee_id;
  final int followedAt;

  Follow({
    required this.follower_id,
    required this.followee_id,
    required this.followedAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      follower_id: json['follower_id'],
      followee_id: json['followee_id'],
      followedAt: json['followedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'follower_id': follower_id,
      'followee_id': followee_id,
      'followedAt': followedAt,
    };
  }
}

class User_inf {
  final String user_id;
  final String user_name;
  final String userImageUrl;
  final int createdAt;

  User_inf({
    required this.user_id,
    required this.user_name,
    required this.userImageUrl,
    required this.createdAt,
  });

  factory User_inf.fromJson(Map<String, dynamic> json) {
    return User_inf(
      user_id: json['user_id'],
      user_name: json['user_name'],
      userImageUrl: json['userImageUrl'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'user_name': user_name,
      'userImageUrl':userImageUrl,
      'createdAt' : createdAt,
    };
  }
}