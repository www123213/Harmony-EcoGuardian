import { User, EcoRecord, EcoActivity, Comment, EcoKnowledge } from '../model/User';
import { preferences } from '@kit.ArkData';

// 数据接口定义
interface RecordData {
  id: string;
  userId: string;
  type: string;
  amount: number;
  carbonReduction: number;
  description?: string;
  date?: string;
  points?: number;
}

interface ActivityData {
  id: string;
  title: string;
  description: string;
  type: string;
  category?: string; // 保持向后兼容
  startTime: string;
  endTime: string;
  location: string;
  maxParticipants: number;
  currentParticipants: number;
  organizer?: string;
  status?: string;
  participants?: string[];
  likes?: number;
  points?: number;
  createdAt?: string;
}

interface KnowledgeData {
  id: string;
  title: string;
  content: string;
  category: string;
  tags?: string[];
  author?: string;
  source?: string;
  readCount?: number;
  views?: number;
  likes?: number;
  createdAt?: string;
}

interface UserData {
  id: string;
  username: string;
  email: string;
  password?: string;
  avatar?: string;
  points?: number;
  carbonReduction?: number;
  level?: number;
  badges?: string[];
  createdAt?: string;
}

// 数据服务类
export class DataService {
  private static instance: DataService;
  private preferencesHelper: preferences.Preferences | null = null;

  private constructor() {}

  public static getInstance(): DataService {
    if (!DataService.instance) {
      DataService.instance = new DataService();
    }
    return DataService.instance;
  }

  // 初始化数据存储
  async init(context: Context): Promise<void> {
    try {
      this.preferencesHelper = await preferences.getPreferences(context, 'eco_app_data');
    } catch (error) {
      console.error('初始化数据存储失败:', error);
    }
  }

  // 用户相关操作
  async saveUser(user: User): Promise<boolean> {
    try {
      const users = await this.getUsers();
      const existingIndex = users.findIndex(u => u.id === user.id);
      
      if (existingIndex >= 0) {
        users[existingIndex] = user;
        console.log('更新用户:', user.email);
      } else {
        users.push(user);
        console.log('新增用户:', user.email);
      }
      
      await this.preferencesHelper?.put('users', JSON.stringify(users));
      await this.preferencesHelper?.flush();
      
      // 验证保存是否成功
      const savedUsers = await this.getUsers();
      const savedUser = savedUsers.find(u => u.email === user.email);
      if (savedUser) {
        console.log('用户保存成功，当前用户总数:', savedUsers.length);
        return true;
      } else {
        console.error('用户保存验证失败');
        return false;
      }
    } catch (error) {
      console.error('保存用户失败:', error);
      return false;
    }
  }

  async getUsers(): Promise<User[]> {
    try {
      const usersData = await this.preferencesHelper?.get('users', '[]') as string;
      const usersArray: UserData[] = JSON.parse(usersData) as UserData[];
      return usersArray.map((userData: UserData): User => {
        const user = new User(
          userData.username || '',
          userData.email || '',
          userData.password || ''
        );
        user.id = userData.id || '';
        user.avatar = userData.avatar || '';
        user.points = userData.points || 0;
        user.carbonReduction = userData.carbonReduction || 0;
        user.level = userData.level || 1;
        user.badges = userData.badges || [];
        user.createdAt = userData.createdAt ? userData.createdAt : new Date().toISOString();
        return user;
      });
    } catch (error) {
      console.error('获取用户列表失败:', error);
      return [];
    }
  }

  async getUserById(id: string): Promise<User | null> {
    const users = await this.getUsers();
    return users.find(user => user.id === id) || null;
  }

  async getUserByEmail(email: string): Promise<User | null> {
    const users = await this.getUsers();
    return users.find(user => user.email === email) || null;
  }

  // 当前登录用户
  async setCurrentUser(user: User): Promise<void> {
    await this.preferencesHelper?.put('currentUser', JSON.stringify(user));
    await this.preferencesHelper?.flush();
  }

  async getCurrentUser(): Promise<User | null> {
    try {
      const userData = await this.preferencesHelper?.get('currentUser', '') as string;
      if (userData) {
        const userObj: UserData = JSON.parse(userData) as UserData;
        const user = new User(
          userObj.username || '',
          userObj.email || '',
          userObj.password || ''
        );
        user.id = userObj.id || '';
        user.avatar = userObj.avatar || '';
        user.points = userObj.points || 0;
        user.carbonReduction = userObj.carbonReduction || 0;
        user.level = userObj.level || 1;
        user.badges = userObj.badges || [];
        user.createdAt = userObj.createdAt ? userObj.createdAt : new Date().toISOString();
        return user;
      }
      return null;
    } catch (error) {
      console.error('获取当前用户失败:', error);
      return null;
    }
  }

  async logout(): Promise<void> {
    await this.preferencesHelper?.delete('currentUser');
    await this.preferencesHelper?.flush();
  }

  // 环保记录相关操作
  async saveEcoRecord(record: EcoRecord): Promise<boolean> {
    try {
      const records = await this.getEcoRecords();
      records.push(record);
      await this.preferencesHelper?.put('ecoRecords', JSON.stringify(records));
      await this.preferencesHelper?.flush();
      return true;
    } catch (error) {
      console.error('保存环保记录失败:', error);
      return false;
    }
  }

  async getEcoRecords(): Promise<EcoRecord[]> {
    try {
      const recordsData = await this.preferencesHelper?.get('ecoRecords', '[]') as string;
      const recordsArray: RecordData[] = JSON.parse(recordsData) as RecordData[];
      return recordsArray.map((recordData: RecordData): EcoRecord => {
        const record = new EcoRecord(
          recordData.userId || '',
          recordData.type || '',
          recordData.description || '',
          recordData.points || 0,
          recordData.carbonReduction || 0
        );
        record.id = recordData.id || '';
        record.amount = recordData.amount || 1;
        record.date = recordData.date ? new Date(recordData.date) : new Date();
        return record;
      });
    } catch (error) {
      console.error('获取环保记录失败:', error);
      return [];
    }
  }

  async getEcoRecordsByUserId(userId: string): Promise<EcoRecord[]> {
    const records = await this.getEcoRecords();
    return records.filter(record => record.userId === userId);
  }

  // 公益活动相关操作
  async saveEcoActivity(activity: EcoActivity): Promise<boolean> {
    try {
      const activities = await this.getEcoActivities();
      const existingIndex = activities.findIndex(a => a.id === activity.id);
      
      if (existingIndex >= 0) {
        activities[existingIndex] = activity;
      } else {
        activities.push(activity);
      }
      
      await this.preferencesHelper?.put('ecoActivities', JSON.stringify(activities));
      await this.preferencesHelper?.flush();
      return true;
    } catch (error) {
      console.error('保存公益活动失败:', error);
      return false;
    }
  }

  async getEcoActivities(): Promise<EcoActivity[]> {
    try {
      const activitiesData = await this.preferencesHelper?.get('ecoActivities', '[]') as string;
      const activitiesArray: ActivityData[] = JSON.parse(activitiesData) as ActivityData[];
      return activitiesArray.map((activityData: ActivityData): EcoActivity => {
        const activity = new EcoActivity(
          activityData.title || '',
          activityData.description || '',
          activityData.type || activityData.category || '',
          activityData.organizer || 'system',
          activityData.startTime ? new Date(activityData.startTime) : new Date(),
          activityData.endTime ? new Date(activityData.endTime) : new Date(),
          activityData.location || '',
          activityData.maxParticipants || 0,
          activityData.points || 50 // 使用数据中的积分或默认50
        );
        activity.id = activityData.id || activity.id;
        activity.currentParticipants = activityData.currentParticipants || 0;
        activity.status = activityData.status || 'active';
        activity.participants = activityData.participants || [];
        activity.likes = activityData.likes || 0;
        activity.createdAt = activityData.createdAt ? activityData.createdAt : new Date().toISOString();
        return activity;
      });
    } catch (error) {
      console.error('获取公益活动失败:', error);
      return [];
    }
  }

  async getEcoActivityById(id: string): Promise<EcoActivity | null> {
    const activities = await this.getEcoActivities();
    return activities.find(activity => activity.id === id) || null;
  }

  // 环保知识相关操作
  async saveEcoKnowledge(knowledge: EcoKnowledge): Promise<boolean> {
    try {
      const knowledgeList = await this.getEcoKnowledgeList();
      const existingIndex = knowledgeList.findIndex(k => k.id === knowledge.id);
      
      if (existingIndex >= 0) {
        // 更新已存在的知识条目
        knowledgeList[existingIndex] = knowledge;
      } else {
        // 添加新的知识条目
        knowledgeList.push(knowledge);
      }
      
      // 直接存储知识列表，不做复杂转换
      await this.preferencesHelper?.put('ecoKnowledge', JSON.stringify(knowledgeList));
      await this.preferencesHelper?.flush();
      return true;
    } catch (error) {
      console.error('保存环保知识失败:', error);
      return false;
    }
  }

  async getEcoKnowledgeList(): Promise<EcoKnowledge[]> {
    try {
      const knowledgeData = await this.preferencesHelper?.get('ecoKnowledge', '[]') as string;
      const knowledgeArray: KnowledgeData[] = JSON.parse(knowledgeData) as KnowledgeData[];
      return knowledgeArray.map((data: KnowledgeData): EcoKnowledge => {
        const knowledge = new EcoKnowledge(
          data.title || '',
          data.content || '',
          data.category || '',
          data.source || data.author || ''
        );
        knowledge.id = data.id || '';
        knowledge.source = data.source || data.author || '';
        knowledge.tags = data.tags || [];
        knowledge.views = data.views || data.readCount || 0;
        knowledge.likes = data.likes || 0;
        knowledge.publishDate = data.createdAt ? new Date(data.createdAt) : new Date();
        return knowledge;
      });
    } catch (error) {
      console.error('获取环保知识失败:', error);
      return [];
    }
  }

  // 获取用户的环保记录
  async getUserRecords(userId: string): Promise<EcoRecord[]> {
    try {
      const records = await this.getEcoRecords()
      return records.filter(record => record.userId === userId)
    } catch (error) {
      console.error('获取用户记录失败:', error)
      return []
    }
  }

  // 获取积分排行榜
  async getPointsRanking(): Promise<User[]> {
    try {
      const users = await this.getUsers()
      return users.sort((a, b) => b.points - a.points)
    } catch (error) {
      console.error('获取积分排行榜失败:', error)
      return []
    }
  }

  // 保存活动
  async saveActivity(activity: EcoActivity): Promise<void> {
    try {
      const activities = await this.getEcoActivities()
      activities.push(activity)
      await this.preferencesHelper?.put('ecoActivities', JSON.stringify(activities))
      await this.preferencesHelper?.flush()
    } catch (error) {
      console.error('保存活动失败:', error)
      throw new Error('保存活动失败')
    }
  }

  // 参与活动
  async joinActivity(activityId: string, userId: string): Promise<void> {
    try {
      const activities = await this.getEcoActivities()
      const activityIndex = activities.findIndex(a => a.id === activityId)
      
      if (activityIndex !== -1) {
        const activity = activities[activityIndex]
        if (!activity.participants.includes(userId) && 
            activity.currentParticipants < activity.maxParticipants) {
          activity.participants.push(userId)
          activity.currentParticipants++
          
          await this.preferencesHelper?.put('ecoActivities', JSON.stringify(activities))
          await this.preferencesHelper?.flush()
        }
      }
    } catch (error) {
      console.error('参与活动失败:', error)
      throw new Error('参与活动失败')
    }
  }

  // 点赞活动
  async likeActivity(activityId: string): Promise<void> {
    try {
      const activities = await this.getEcoActivities()
      const activityIndex = activities.findIndex(a => a.id === activityId)
      
      if (activityIndex !== -1) {
        activities[activityIndex].likes++
        await this.preferencesHelper?.put('ecoActivities', JSON.stringify(activities))
        await this.preferencesHelper?.flush()
      }
    } catch (error) {
      console.error('点赞活动失败:', error)
      throw new Error('点赞活动失败')
    }
  }

  // 清除所有数据（用于测试）
  async clearAllData(): Promise<void> {
    await this.preferencesHelper?.clear();
    await this.preferencesHelper?.flush();
  }

  // 清理损坏的活动数据
  async clearCorruptedActivityData(): Promise<void> {
    try {
      await this.preferencesHelper?.delete('ecoActivities');
      await this.preferencesHelper?.flush();
      console.log('已清理损坏的活动数据');
    } catch (error) {
      console.error('清理活动数据失败:', error);
    }
  }

  // 清理损坏的环保知识数据
  async clearCorruptedKnowledgeData(): Promise<void> {
    try {
      await this.preferencesHelper?.delete('ecoKnowledge');
      await this.preferencesHelper?.flush();
      console.log('已清理损坏的环保知识数据');
    } catch (error) {
      console.error('清理环保知识数据失败:', error);
    }
  }

  // 初始化示例数据
  async initSampleData(): Promise<void> {
    const activities = await this.getEcoActivities();
    // 检查是否存在乱码数据，如果存在则清理重新生成
    const hasCorruptedData = activities.some(activity => 
      !activity.title || activity.title.length > 50 || /^[0-9a-f]{10,}/.test(activity.title)
    );
    
    if (activities.length === 0 || hasCorruptedData) {
      // 清理现有数据
      if (hasCorruptedData) {
        await this.preferencesHelper?.delete('ecoActivities');
        await this.preferencesHelper?.flush();
      }
      // 创建示例活动
      const sampleActivities = [
        new EcoActivity(
          '社区垃圾分类志愿活动',
          '帮助社区居民学习正确的垃圾分类方法，共同建设美丽家园',
          '垃圾分类',
          'system',
          new Date(Date.now() + 24 * 60 * 60 * 1000), // 明天
          new Date(Date.now() + 24 * 60 * 60 * 1000 + 4 * 60 * 60 * 1000), // 明天+4小时
          '阳光社区广场',
          20,
          50
        ),
        new EcoActivity(
          '城市公园植树活动',
          '为城市增添绿色，改善空气质量，每人可种植2-3棵树苗',
          '植树造林',
          'system',
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 一周后
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000 + 6 * 60 * 60 * 1000), // 一周后+6小时
          '中央公园东门',
          50,
          80
        ),
        new EcoActivity(
          '海滩清理环保行动',
          '清理海滩垃圾，保护海洋生态环境，让海滩重现美丽',
          '海滩清理',
          'system',
          new Date(Date.now() + 14 * 24 * 60 * 60 * 1000), // 两周后
          new Date(Date.now() + 14 * 24 * 60 * 60 * 1000 + 5 * 60 * 60 * 1000), // 两周后+5小时
          '金沙海滩',
          30,
          100
        )
      ];

      for (const activity of sampleActivities) {
        await this.saveEcoActivity(activity);
      }
    }

    // 创建示例环保知识
    const knowledge = await this.getEcoKnowledgeList();
    // 检查是否存在乱码数据
    const hasCorruptedKnowledge = knowledge.some(item => 
      !item.title || item.title.length > 100 || /^[0-9a-f]{10,}/.test(item.title) ||
      !item.content || item.content.length < 10
    );
    
    if (knowledge.length === 0 || hasCorruptedKnowledge) {
      // 清理现有数据
      if (hasCorruptedKnowledge) {
        await this.preferencesHelper?.delete('ecoKnowledge');
        await this.preferencesHelper?.flush();
        console.log('已清理损坏的环保知识数据');
      }
      const sampleKnowledge = [
        new EcoKnowledge(
          '垃圾分类小贴士',
          '正确的垃圾分类可以减少环境污染，提高资源回收利用率。可回收垃圾包括纸类、塑料、金属等；有害垃圾包括电池、灯管等；湿垃圾是易腐烂的生物质废料；干垃圾是其他垃圾。',
          '垃圾分类',
          '环保局官网'
        ),
        new EcoKnowledge(
          '节约用水的方法',
          '1.洗手时及时关闭水龙头 2.使用节水型马桶和花洒 3.收集雨水浇花 4.洗菜水可以用来浇花 5.修复漏水的水管和设备',
          '节约用水',
          '水务局'
        ),
        new EcoKnowledge(
          '低碳出行倡议',
          '选择步行、骑行、公共交通等绿色出行方式，减少私家车使用。每少开车1公里，可减少约0.2公斤二氧化碳排放。',
          '低碳出行',
          '交通部门'
        )
      ];

      for (const item of sampleKnowledge) {
        await this.saveEcoKnowledge(item);
      }
    }
  }
}