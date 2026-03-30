class PlayerGroup {
  final int? id;
  final String teamName;
  final String level;
  final int slotsNeeded;
  final String sport;
  final String sportEmoji;
  final String time;
  final String location;
  final bool isJoined;
  final bool isCreator;
  final int maxPlayers;
  final int currentPlayers;

  PlayerGroup({
    this.id,
    required this.teamName,
    required this.level,
    required this.slotsNeeded,
    required this.sport,
    this.sportEmoji = '🏅',
    required this.time,
    required this.location,
    this.isJoined = false,
    this.isCreator = false,
    this.maxPlayers = 10,
    this.currentPlayers = 1,
  });

  factory PlayerGroup.fromJson(Map<String, dynamic> json) => PlayerGroup(
        id: json['id'] as int?,
        teamName: json['creator_username'] as String? ?? '',
        level: json['level'] as String? ?? '',
        slotsNeeded: json['slots_needed'] as int? ?? 1,
        sport: json['sport'] as String? ?? '',
        sportEmoji: json['sport_emoji'] as String? ?? '🏅',
        time: '${json['date'] ?? ''} • ${json['time'] ?? ''}',
        location: json['venue_name'] as String? ?? '',
        isJoined: json['is_joined'] as bool? ?? false,
        isCreator: json['is_creator'] as bool? ?? false,
        maxPlayers: json['max_players'] as int? ?? 10,
        currentPlayers: json['current_players_count'] as int? ?? 1,
      );
}

class Venue {
  final int? id;
  final String name;
  final String imageUrl;
  final double rating;
  final String price;
  final String sport;
  final String address;
  final String opensAt;
  final String closesAt;

  Venue({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.sport,
    required this.address,
    this.opensAt = '07:00',
    this.closesAt = '23:00',
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        price: json['price'] as String? ?? '',
        sport: json['sport'] as String? ?? '',
        address: json['address'] as String? ?? '',
        opensAt: json['opens_at'] as String? ?? '07:00',
        closesAt: json['closes_at'] as String? ?? '23:00',
      );
}

class GameItem {
  final String venueName;
  final String sport;
  final String sportEmoji;
  final String dateTime;
  final String location;
  final String players;
  final String status;

  GameItem({
    required this.venueName,
    required this.sport,
    required this.sportEmoji,
    required this.dateTime,
    required this.location,
    required this.players,
    required this.status,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
        venueName: json['venue_name'] as String? ?? '',
        sport: json['sport'] as String? ?? '',
        sportEmoji: json['sport_emoji'] as String? ?? '🏅',
        dateTime: json['date_time'] as String? ?? '',
        location: json['location'] as String? ?? '',
        players: json['players'] as String? ?? '0/0',
        status: json['status'] as String? ?? '',
      );
}

class ChatItem {
  final int id;
  final String type; // 'game' | 'direct'
  final String name;
  final String sportEmoji;
  final String lastMessage;
  final String time;
  final int unread;
  final int? gameId;
  final int? otherUserId;
  final String? otherUsername;

  ChatItem({
    required this.id,
    required this.type,
    required this.name,
    required this.sportEmoji,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.gameId,
    this.otherUserId,
    this.otherUsername,
  });

  bool get isOnline => false;
  String get teamName => name;

  factory ChatItem.fromJson(Map<String, dynamic> json) => ChatItem(
        id: json['id'] as int? ?? 0,
        type: json['type'] as String? ?? 'direct',
        name: json['name'] as String? ?? '',
        sportEmoji: json['sport_emoji'] as String? ?? '💬',
        lastMessage: json['last_message'] as String? ?? '',
        time: json['last_message_time'] as String? ?? '',
        unread: json['unread_count'] as int? ?? 0,
        gameId: json['game_id'] as int?,
        otherUserId: json['other_user_id'] as int?,
        otherUsername: json['other_username'] as String?,
      );
}

class ChatMessage {
  final int id;
  final String senderUsername;
  final bool isMine;
  final String text;
  final String time;

  ChatMessage({
    required this.id,
    required this.senderUsername,
    required this.isMine,
    required this.text,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int? ?? 0,
        senderUsername: json['sender_username'] as String? ?? '',
        isMine: json['is_mine'] as bool? ?? false,
        text: json['text'] as String? ?? '',
        time: json['time'] as String? ?? '',
      );
}

// Mock data
class MockData {
  static List<PlayerGroup> playerGroups = [
    PlayerGroup(
      teamName: 'FC ALPHA',
      level: 'СРЕДНИЙ',
      slotsNeeded: 4,
      sport: 'Футбол',
      time: '18:00',
      location: 'Стадион Спартак',
    ),
    PlayerGroup(
      teamName: 'BASKET KINGS',
      level: 'ПРОФИ',
      slotsNeeded: 2,
      sport: 'Баскетбол',
      time: '19:30',
      location: 'Зал Динамо',
    ),
    PlayerGroup(
      teamName: 'ВОЛНА',
      level: 'СРЕДНИЙ',
      slotsNeeded: 6,
      sport: 'Волейбол',
      time: '20:00',
      location: 'Пляж Иссык-Куль',
    ),
  ];

  static List<Venue> venues = [
    Venue(
      name: 'СПОРТКОМ АРЕНА',
      imageUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800',
      rating: 4.8,
      price: '800 СОМ/ЧАС',
      sport: 'Футбол',
      address: 'ул. Московская 45',
    ),
    Venue(
      name: 'БАСКЕТ ХОЛЛ',
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
      rating: 4.6,
      price: '600 СОМ/ЧАС',
      sport: 'Баскетбол',
      address: 'пр. Манаса 12',
    ),
    Venue(
      name: 'AQUA SPORT',
      imageUrl: 'https://images.unsplash.com/photo-1575429198097-0414ec08e8cd?w=800',
      rating: 4.9,
      price: '1200 СОМ/ЧАС',
      sport: 'Плавание',
      address: 'ул. Токтогула 89',
    ),
  ];

  static List<GameItem> upcomingGames = [
    GameItem(
      venueName: 'СПОРТКОМ АРЕНА',
      sport: 'Футбол',
      sportEmoji: '⚽',
      dateTime: '24 ОКТ • 20:00',
      location: 'ул. Московская 45',
      players: '8/10',
      status: 'ПОДТВЕРЖДЕН',
    ),
    GameItem(
      venueName: 'БАСКЕТ ХОЛЛ',
      sport: 'Баскетбол',
      sportEmoji: '🏀',
      dateTime: '26 ОКТ • 19:30',
      location: 'пр. Манаса 12',
      players: '5/10',
      status: 'ОЖИДАНИЕ',
    ),
    GameItem(
      venueName: 'AQUA SPORT',
      sport: 'Плавание',
      sportEmoji: '🏊',
      dateTime: '28 ОКТ • 07:00',
      location: 'ул. Токтогула 89',
      players: '3/6',
      status: 'ПОДТВЕРЖДЕН',
    ),
  ];

  static List<GameItem> historyGames = [
    GameItem(
      venueName: 'СТАДИОН СПАРТАК',
      sport: 'Футбол',
      sportEmoji: '⚽',
      dateTime: '10 ОКТ • 18:00',
      location: 'ул. Фрунзе 110',
      players: '10/10',
      status: 'ЗАВЕРШЕН',
    ),
    GameItem(
      venueName: 'ВОЛЕЙ ЦЕНТР',
      sport: 'Волейбол',
      sportEmoji: '🏐',
      dateTime: '05 ОКТ • 20:30',
      location: 'пр. Чуй 77',
      players: '12/12',
      status: 'ЗАВЕРШЕН',
    ),
  ];

  static List<ChatItem> chats = [
    ChatItem(
      id: 1, type: 'game', name: 'FC ALPHA',
      sportEmoji: '⚽', lastMessage: 'Все подтвердили на завтра?',
      time: '20:45', unread: 3,
    ),
    ChatItem(
      id: 2, type: 'game', name: 'BASKET KINGS',
      sportEmoji: '🏀', lastMessage: 'Зал свободен, берем!',
      time: '19:12', unread: 1,
    ),
    ChatItem(
      id: 3, type: 'direct', name: 'AQUA TEAM',
      sportEmoji: '💬', lastMessage: 'Отличная тренировка сегодня!',
      time: '16:30',
    ),
  ];
}
