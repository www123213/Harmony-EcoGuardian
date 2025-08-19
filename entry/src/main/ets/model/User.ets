// 用户模型
export class User {
  id: string;
  username: string;
  email: string;
  password: string;
  avatar: string;
  points: number;
  level: number;
  joinDate: Date;
  carbonReduction: number; // 累计减排量
  badges: string[]; // 获得的勋章
  createdAt: string; // 创建时间

  constructor(username: string, email: string, password: string) {
    this.id = this.generateId();
    this.username = username;
    this.email = email;
    this.password = password;
    this.avatar = '';
    this.points = 0;
    this.level = 1;
    this.joinDate = new Date();
    this.carbonReduction = 0;
    this.badges = [];
    this.createdAt = new Date().toISOString();
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  // 增加积分
  addPoints(points: number): void {
    this.points += points;
    this.updateLevel();
  }

  // 更新等级
  private updateLevel(): void {
    this.level = Math.floor(this.points / 100) + 1;
  }

  // 添加勋章
  addBadge(badge: string): void {
    if (!this.badges.includes(badge)) {
      this.badges.push(badge);
    }
  }

  // 增加减排量
  addCarbonReduction(amount: number): void {
    this.carbonReduction += amount;
  }
}

// 环保记录模型
export class EcoRecord {
  id: string;
  userId: string;
  type: string; // 环保行为类型
  description: string;
  amount: number; // 数量
  points: number;
  carbonReduction: number;
  date: Date;
  location?: string;
  photos?: string[];

  constructor(userId: string, type: string, description: string, points: number, carbonReduction: number) {
    this.id = this.generateId();
    this.userId = userId;
    this.type = type;
    this.description = description;
    this.amount = 1; // 默认数量为1
    this.points = points;
    this.carbonReduction = carbonReduction;
    this.date = new Date();
    this.photos = [];
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }
}

// 公益活动模型
export class EcoActivity {
  id: string;
  title: string;
  description: string;
  type: string; // 活动类型：垃圾分类、植树、海滩清理等
  organizer: string;
  startTime: Date;
  endTime: Date;
  location: string;
  maxParticipants: number;
  currentParticipants: number;
  participants: string[]; // 参与者用户ID列表
  points: number; // 参与可获得的积分
  status: string; // 活动状态：upcoming, ongoing, completed
  images?: string[];
  likes: number;
  comments: Comment[];
  createdAt: string; // 创建时间
  likedBy: string[] = []; //用户点赞

  constructor(title: string, description: string, type: string, organizer: string, 
              startTime: Date, endTime: Date, location: string, maxParticipants: number, points: number) {
    this.id = this.generateId();
    this.title = title;
    this.description = description;
    this.type = type;
    this.organizer = organizer;
    this.startTime = startTime;
    this.endTime = endTime;
    this.location = location;
    this.maxParticipants = maxParticipants;
    this.currentParticipants = 0;
    this.participants = [];
    this.points = points;
    this.status = 'upcoming';
    this.images = [];
    this.likes = 0;
    this.comments = [];
    this.createdAt = new Date().toISOString();
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  // 添加参与者
  addParticipant(userId: string): boolean {
    if (this.currentParticipants < this.maxParticipants && !this.participants.includes(userId)) {
      this.participants.push(userId);
      this.currentParticipants++;
      return true;
    }
    return false;
  }

  // 移除参与者
  removeParticipant(userId: string): boolean {
    const index = this.participants.indexOf(userId);
    if (index > -1) {
      this.participants.splice(index, 1);
      this.currentParticipants--;
      return true;
    }
    return false;
  }

  // 点赞
  toggleLike(userId: string): boolean {
    const index = this.likedBy.indexOf(userId);
    if (index === -1) {
      // 添加点赞
      this.likedBy.push(userId);
      this.likes++;
      return true; // 返回true表示添加了点赞
    } else {
      // 取消点赞
      this.likedBy.splice(index, 1);
      this.likes--;
      return false; // 返回false表示取消了点赞
    }
  }

  // 添加检查用户是否点赞的方法
  isLikedByUser(userId: string): boolean {
    return this.likedBy.indexOf(userId) !== -1;
  }

  // 添加评论
  addComment(comment: Comment): void {
    this.comments.push(comment);
  }
}

// 评论模型
export class Comment {
  id: string;
  userId: string;
  username: string;
  content: string;
  date: Date;
  likes: number;

  constructor(userId: string, username: string, content: string) {
    this.id = this.generateId();
    this.userId = userId;
    this.username = username;
    this.content = content;
    this.date = new Date();
    this.likes = 0;
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }
}

// 环保知识模型
export class EcoKnowledge {
  id: string;
  title: string;
  content: string;
  category: string;
  source: string;
  publishDate: Date;
  views: number;
  likes: number;
  author: string; // 作者
  tags: string[]; // 标签

  constructor(title: string, content: string, category: string, source: string) {
    this.id = this.generateId();
    this.title = title;
    this.content = content;
    this.category = category;
    this.source = source;
    this.publishDate = new Date();
    this.views = 0;
    this.likes = 0;
    this.author = '';
    this.tags = [];
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  // 增加浏览量
  addView(): void {
    this.views++;
  }
  
  // 增加点赞数
  addLike(): void {
    this.likes++;
  }
}