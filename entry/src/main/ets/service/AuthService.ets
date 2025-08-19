import { User } from '../model/User';
import { DataService } from './DataService';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

// 接口定义
interface RegisterResult {
  success: boolean;
  message: string;
  user?: User;
}

interface LoginResult {
  success: boolean;
  message: string;
  user?: User;
}

interface ValidationResult {
  valid: boolean;
  message: string;
}

interface LogoutResult {
  success: boolean;
  message: string;
}

interface UpdateResult {
  success: boolean;
  message: string;
}

// 认证服务类
export class AuthService {
  private static instance: AuthService;
  private dataService: DataService;

  private constructor() {
    this.dataService = DataService.getInstance();
  }

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  // 用户注册
  async register(username: string, email: string, password: string): Promise<RegisterResult> {
    try {
      console.log('开始注册用户:', email);
      
      // 验证输入
      const validation = this.validateInput(username, email, password);
      if (!validation.valid) {
        console.log('输入验证失败:', validation.message);
        return { success: false, message: validation.message } as RegisterResult;
      }

      // 检查邮箱是否已存在
      const existingUser = await this.dataService.getUserByEmail(email);
      if (existingUser) {
        console.log('邮箱已存在:', email);
        return { success: false, message: '该邮箱已被注册' } as RegisterResult;
      }

      // 加密密码
      console.log('正在加密密码...');
      const hashedPassword = await this.hashPassword(password);
      
      // 创建新用户
      const newUser = new User(username, email, password);
      newUser.password = hashedPassword; // 设置加密后的密码
      console.log('创建新用户对象:', newUser.id, newUser.email);
      
      // 保存用户
      console.log('正在保存用户...');
      const saved = await this.dataService.saveUser(newUser);
      if (saved) {
        console.log('用户注册成功:', email);
        return { success: true, message: '注册成功', user: newUser } as RegisterResult;
      } else {
        console.error('用户保存失败:', email);
        return { success: false, message: '注册失败，请重试' } as RegisterResult;
      }
    } catch (error) {
      console.error('注册失败:', error);
      return { success: false, message: '注册失败，系统错误' } as RegisterResult;
    }
  }

  // 用户登录
  async login(email: string, password: string): Promise<LoginResult> {
    try {
      // 验证输入
      if (!email || !password) {
        return { success: false, message: '请输入邮箱和密码' } as LoginResult;
      }

      if (!this.isValidEmail(email)) {
        return { success: false, message: '请输入有效的邮箱地址' } as LoginResult;
      }

      // 查找用户
      console.log('正在查找用户:', email);
      const allUsers = await this.dataService.getUsers();
      console.log('当前系统中的用户总数:', allUsers.length);
      console.log('所有用户邮箱:', allUsers.map(u => u.email));
      
      const user = await this.dataService.getUserByEmail(email);
      if (!user) {
        console.error('用户不存在:', email);
        return { success: false, message: '用户不存在' } as LoginResult;
      }
      
      console.log('找到用户:', user.email);

      // 验证密码
      const passwordValid = await this.verifyPassword(password, user.password);
      if (!passwordValid) {
        return { success: false, message: '密码错误' } as LoginResult;
      }

      // 设置当前用户
      await this.dataService.setCurrentUser(user);
      
      return { success: true, message: '登录成功', user: user } as LoginResult;
    } catch (error) {
      console.error('登录失败:', error);
      return { success: false, message: '登录失败，系统错误' } as LoginResult;
    }
  }

  // 用户登出
  async logout(): Promise<LogoutResult> {
    try {
      await this.dataService.logout();
      return { success: true, message: '登出成功' } as LogoutResult;
    } catch (error) {
      console.error('登出失败:', error);
      return { success: false, message: '登出失败' } as LogoutResult;
    }
  }

  // 获取当前用户
  async getCurrentUser(forceRefresh: boolean = false): Promise<User | null> {
    try {
      if (forceRefresh) {
        // 强制从数据服务获取最新用户数据
        const currentUser = await this.dataService.getCurrentUser();
        if (currentUser) {
          // 重新从数据库获取最新的用户数据
          const freshUser = await this.dataService.getUserById(currentUser.id);
          if (freshUser) {
            // 更新当前用户
            await this.dataService.setCurrentUser(freshUser);
            return freshUser;
          }
        }
        return null;
      }
      return await this.dataService.getCurrentUser();
    } catch (error) {
      console.error('获取当前用户失败:', error);
      return null;
    }
  }

  // 更新用户信息
  async updateUserProfile(userId: string, updates: Partial<User>): Promise<UpdateResult> {
    try {
      const user = await this.dataService.getUserById(userId);
      if (!user) {
        return { success: false, message: '用户不存在' } as LoginResult;
      }

      // 更新用户信息
      if (updates.username !== undefined) user.username = updates.username;
      if (updates.email !== undefined) user.email = updates.email;
      if (updates.password !== undefined) user.password = updates.password;
      if (updates.avatar !== undefined) user.avatar = updates.avatar;
      if (updates.points !== undefined) user.points = updates.points;
      if (updates.carbonReduction !== undefined) user.carbonReduction = updates.carbonReduction;
      if (updates.level !== undefined) user.level = updates.level;
      if (updates.badges !== undefined) user.badges = updates.badges;
      if (updates.createdAt !== undefined) user.createdAt = updates.createdAt;
      
      const saved = await this.dataService.saveUser(user);
      if (saved) {
        // 如果是当前用户，更新当前用户信息
        const currentUser = await this.dataService.getCurrentUser();
        if (currentUser && currentUser.id === userId) {
          await this.dataService.setCurrentUser(user);
        }
        return { success: true, message: '更新成功' } as UpdateResult;
      } else {
        return { success: false, message: '更新失败' } as UpdateResult;
      }
    } catch (error) {
      console.error('更新用户信息失败:', error);
      return { success: false, message: '更新失败，系统错误' } as UpdateResult;
    }
  }

  // 修改密码
  async changePassword(userId: string, oldPassword: string, newPassword: string): Promise<UpdateResult> {
    try {
      const user = await this.dataService.getUserById(userId);
      if (!user) {
        return { success: false, message: '用户不存在' } as LoginResult;
      }

      // 验证旧密码
      const oldPasswordValid = await this.verifyPassword(oldPassword, user.password);
      if (!oldPasswordValid) {
        return { success: false, message: '原密码错误' } as UpdateResult;
      }

      // 验证新密码
      if (!this.isValidPassword(newPassword)) {
        return { success: false, message: '新密码格式不正确，至少6位字符' } as UpdateResult;
      }

      // 加密新密码
      const hashedNewPassword = await this.hashPassword(newPassword);
      user.password = hashedNewPassword;

      const saved = await this.dataService.saveUser(user);
      if (saved) {
        return { success: true, message: '密码修改成功' } as UpdateResult;
      } else {
        return { success: false, message: '密码修改失败' } as UpdateResult;
      }
    } catch (error) {
      console.error('修改密码失败:', error);
      return { success: false, message: '修改密码失败，系统错误' } as UpdateResult;
    }
  }

  // 检查用户是否已登录
  async isLoggedIn(): Promise<boolean> {
    const currentUser = await this.getCurrentUser();
    return currentUser !== null;
  }

  // 输入验证
  private validateInput(username: string, email: string, password: string): ValidationResult {
    if (!username || username.trim().length < 2) {
      return { valid: false, message: '用户名至少2个字符' } as ValidationResult;
    }

    if (!email || !this.isValidEmail(email)) {
      return { valid: false, message: '请输入有效的邮箱地址' } as ValidationResult;
    }

    if (!password || !this.isValidPassword(password)) {
      return { valid: false, message: '密码至少6位字符' } as ValidationResult;
    }

    return { valid: true, message: '' } as ValidationResult;
  }

  // 邮箱格式验证
  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  // 密码格式验证
  private isValidPassword(password: string): boolean {
    return password.length >= 6;
  }

  // 密码加密（简化版，实际项目中应使用更安全的加密方式）
  private async hashPassword(password: string): Promise<string> {
    try {
      // 使用简单的字符串哈希算法
      let hash = 0;
      const saltedPassword = password + 'eco_app_salt';
      for (let i = 0; i < saltedPassword.length; i++) {
        const char = saltedPassword.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convert to 32bit integer
      }
      return Math.abs(hash).toString(16);
    } catch (error) {
      console.error('密码加密失败:', error);
      // 降级到简单编码
      return (password + 'eco_app_salt').split('').map(c => c.charCodeAt(0).toString(16)).join('');
    }
  }

  // 密码验证
  private async verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
    try {
      const hashedInput = await this.hashPassword(password);
      return hashedInput === hashedPassword;
    } catch (error) {
      console.error('密码验证失败:', error);
      return false;
    }
  }

  // 生成随机头像（可以扩展为选择头像功能）
  generateRandomAvatar(): string {
    const avatars = [
      '🌱', '🌿', '🌳', '🌲', '🍃', '🌾', '🌻', '🌺', '🌸', '🌼',
      '🐝', '🦋', '🐛', '🐞', '🌍', '🌎', '🌏', '♻️', '🌈', '☀️'
    ];
    return avatars[Math.floor(Math.random() * avatars.length)];
  }

  // 更新用户信息
  async updateUserInfo(updatedUser: User): Promise<void> {
    try {
      await this.dataService.saveUser(updatedUser);
      await this.dataService.setCurrentUser(updatedUser);
    } catch (error) {
      console.error('更新用户信息失败:', error);
      throw new Error('更新用户信息失败');
    }
  }
}