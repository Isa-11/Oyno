class PlayerGroup {
  final String teamName;
  final String level;
  final int slotsNeeded;
  final String sport;
  final String time;
  final String location;

  PlayerGroup({
    required this.teamName,
    required this.level,
    required this.slotsNeeded,
    required this.sport,
    required this.time,
    required this.location,
  });
}

class Venue {
  final String name;
  final String imageUrl;
  final double rating;
  final String price;
  final String sport;
  final String address;

  Venue({
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.sport,
    required this.address,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        name: json['name'] as String,
        imageUrl: json['image_url'] as String,
        rating: (json['rating'] as num).toDouble(),
        price: json['price'] as String,
        sport: json['sport'] as String,
        address: json['address'] as String,
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
}

class ChatItem {
  final String teamName;
  final String sportEmoji;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unread;

  ChatItem({
    required this.teamName,
    required this.sportEmoji,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    this.unread = 0,
  });
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
      teamName: 'FC ALPHA',
      sportEmoji: '⚽',
      lastMessage: 'Все подтвердили на завтра?',
      time: '20:45',
      isOnline: true,
      unread: 3,
    ),
    ChatItem(
      teamName: 'BASKET KINGS',
      sportEmoji: '🏀',
      lastMessage: 'Зал свободен, берем!',
      time: '19:12',
      isOnline: true,
      unread: 1,
    ),
    ChatItem(
      teamName: 'AQUA TEAM',
      sportEmoji: '🏊',
      lastMessage: 'Отличная тренировка сегодня!',
      time: '16:30',
      isOnline: false,
    ),
    ChatItem(
      teamName: 'ВОЛНА',
      sportEmoji: '🏐',
      lastMessage: 'Нужен ещё один игрок',
      time: 'Вчера',
      isOnline: false,
    ),
    ChatItem(
      teamName: 'BISHKEK UNITED',
      sportEmoji: '⚽',
      lastMessage: 'Когда следующая игра?',
      time: 'Вчера',
      isOnline: true,
    ),
  ];
}
