import { AuthService } from '../service/AuthService';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State email: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  private authService: AuthService = AuthService.getInstance();

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button('← 返回')
          .backgroundColor(Color.Transparent)
          .fontColor('#333')
          .onClick(() => {
            router.back();
          })
        
        Blank()
        
        Text('注册')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        // 占位，保持标题居中
        Text('')
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      Scroll() {
        // 注册表单
        Column({ space: 20 }) {
          // Logo
          Column({ space: 10 }) {
            Text('🌱')
              .fontSize(80)
            Text('加入我们')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2E7D32')
            Text('开始你的环保之旅')
              .fontSize(16)
              .fontColor('#666')
          }
          .margin({ top: 40, bottom: 30 })

          // 用户名输入
          Column({ space: 8 }) {
            Text('用户名')
              .fontSize(14)
              .fontColor('#333')
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请输入用户名（至少2个字符）' })
              .width('100%')
              .height(50)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.username = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 邮箱输入
          Column({ space: 8 }) {
            Text('邮箱')
              .fontSize(14)
              .fontColor('#333')
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请输入邮箱地址' })
              .width('100%')
              .height(50)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .type(InputType.Email)
              .onChange((value: string) => {
                this.email = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 密码输入
          Column({ space: 8 }) {
            Text('密码')
              .fontSize(14)
              .fontColor('#333')
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请输入密码（至少6位字符）' })
              .width('100%')
              .height(50)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .type(InputType.Password)
              .onChange((value: string) => {
                this.password = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 确认密码输入
          Column({ space: 8 }) {
            Text('确认密码')
              .fontSize(14)
              .fontColor('#333')
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请再次输入密码' })
              .width('100%')
              .height(50)
              .backgroundColor('#f8f8f8')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .type(InputType.Password)
              .onChange((value: string) => {
                this.confirmPassword = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 注册按钮
          Button(this.isLoading ? '注册中...' : '注册')
            .width('100%')
            .height(50)
            .backgroundColor('#4CAF50')
            .borderRadius(25)
            .fontSize(18)
            .fontColor('#fff')
            .enabled(!this.isLoading)
            .onClick(() => {
              this.handleRegister()
            })

          // 登录链接
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#666')
            
            Text('立即登录')
              .fontSize(14)
              .fontColor('#4CAF50')
              .onClick(() => {
                router.replaceUrl({ url: 'pages/LoginPage' });
              })
          }
          .margin({ top: 20 })

          // 环保承诺
          Column({ space: 10 }) {
            Text('🌍 环保承诺')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4CAF50')
            Text('注册即表示您愿意参与环保行动，为地球环境贡献一份力量')
              .fontSize(12)
              .fontColor('#666')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#E8F5E8')
          .borderRadius(8)
          .margin({ top: 20 })
        }
        .width('100%')
        .padding({ left: 30, right: 30, bottom: 30 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  async handleRegister() {
    // 验证输入
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' })
      return
    }

    if (this.username.trim().length < 2) {
      promptAction.showToast({ message: '用户名至少2个字符' })
      return
    }

    if (!this.email.trim()) {
      promptAction.showToast({ message: '请输入邮箱' })
      return
    }

    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' })
      return
    }

    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位字符' })
      return
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' })
      return
    }

    this.isLoading = true;

    try {
      const result = await this.authService.register(
        this.username.trim(),
        this.email.trim(),
        this.password
      )
      
      if (result.success) {
        promptAction.showToast({ message: '注册成功，正在登录...' })
        
        // 添加延迟确保数据已完全保存
        await new Promise<void>((resolve) => setTimeout(resolve, 1000))
        
        // 自动登录
        const loginResult = await this.authService.login(this.email.trim(), this.password)
        if (loginResult.success) {
          promptAction.showToast({ message: '登录成功' })
          // 返回主页
          router.replaceUrl({ url: 'pages/Index' })
        } else {
          console.error('自动登录失败:', loginResult.message)
          // 注册成功但登录失败，跳转到登录页
          promptAction.showToast({ message: '注册成功，请手动登录' })
          router.replaceUrl({ url: 'pages/LoginPage' })
        }
      } else {
        promptAction.showToast({ message: result.message })
      }
    } catch (error) {
      console.error('注册失败:', error)
      promptAction.showToast({ message: '注册失败，请重试' })
    } finally {
      this.isLoading = false;
    }
  }
}