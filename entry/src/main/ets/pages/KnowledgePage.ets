import { DataService } from '../service/DataService';
import { EcoKnowledge } from '../model/User';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct KnowledgePage {
  @State knowledgeList: EcoKnowledge[] = [];
  @State selectedCategory: string = '全部';
  @State isLoading: boolean = true;
  @State searchKeyword: string = '';
  
  private dataService: DataService = DataService.getInstance();
  private categories: string[] = ['全部', '垃圾分类', '节约用水', '低碳出行', '节能减排', '绿色生活'];

  async aboutToAppear() {
    await this.loadKnowledgeData();
  }

  async onPageShow() {
    // 每次页面显示时重新加载最新数据
    await this.loadKnowledgeData();
  }

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
        
        Text('环保知识')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Text('')
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#fff')

      Column() {
        // 搜索框
        Row() {
          TextInput({ placeholder: '搜索环保知识...' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#f0f0f0')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.searchKeyword = value
            })
          
          Button(){
            Text('🔍')
              .fontSize(25)
          }
            .width(40)
            .height(40)
            .backgroundColor('#4CAF50')
            .borderRadius(20)
            .margin({ left: 10 })
            .onClick(() => {
              this.filterKnowledge()
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })

        // 分类标签
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.categories, (category: string) => {
              Text(category)
                .fontSize(14)
                .fontColor(this.selectedCategory === category ? '#fff' : '#333')
                .backgroundColor(this.selectedCategory === category ? '#4CAF50' : '#f0f0f0')
                .padding({ top: 6, bottom: 6, left: 12, right: 12 })
                .borderRadius(15)
                .onClick(() => {
                  this.selectedCategory = category;
                  this.filterKnowledge()
                })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(40)

        // 知识列表
        if (this.isLoading) {
          Column() {
            Text('加载中...')
              .fontSize(16)
              .fontColor('#666')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 10 }) {
            ForEach(this.getFilteredKnowledge(), (knowledge: EcoKnowledge) => {
              ListItem() {
                this.buildKnowledgeItem(knowledge)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, bottom: 16 })
        }

        // 底部提示
        Row() {
          Text('💡 提示：点击文章可查看详细内容')
            .fontSize(12)
            .fontColor('#999')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#f8f8f8')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder buildKnowledgeItem(knowledge: EcoKnowledge) {
    Column({ space: 10 }) {
      // 标题和分类
      Row() {
        Text(knowledge.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        Text(knowledge.category)
          .fontSize(12)
          .fontColor('#4CAF50')
          .backgroundColor('#E8F5E8')
          .padding({ top: 4, bottom: 4, left: 8, right: 8 })
          .borderRadius(10)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 内容预览
      Text(knowledge.content)
        .fontSize(14)
        .fontColor('#666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)

      // 底部信息
      Row() {
        Text(`来源：${knowledge.source}`)
          .fontSize(12)
          .fontColor('#999')
        
        Blank()
        
        Row({ space: 15 }) {
          Row({ space: 4 }) {
            Text('👁')
              .fontSize(12)
            Text(knowledge.views.toString())
              .fontSize(12)
              .fontColor('#999')
          }
          
          Row({ space: 4 }) {
            Text('👍')
              .fontSize(12)
            Text(knowledge.likes.toString())
              .fontSize(12)
              .fontColor('#999')
          }
        }
      }
      .width('100%')

      // 发布时间
      Text(this.formatDate(knowledge.publishDate))
        .fontSize(12)
        .fontColor('#ccc')
        .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#fff')
    .borderRadius(10)
    .onClick(() => {
      this.viewKnowledgeDetail(knowledge)
    })
  }

  private async loadKnowledgeData() {
    try {
      // 初始化数据服务
      await this.dataService.init(getContext(this))
      
      this.knowledgeList = await this.dataService.getEcoKnowledgeList()
      
      // 检查是否存在乱码数据
      const hasCorruptedData = this.knowledgeList.some(item => 
        !item.title || item.title.length > 100 || /^[0-9a-f]{10,}/.test(item.title) ||
        !item.content || item.content.length < 10
      );
      
      if (hasCorruptedData) {
        console.log('检测到环保知识乱码数据，正在清理...');
        await this.dataService.clearCorruptedKnowledgeData();
        await this.dataService.initSampleData();
        this.knowledgeList = await this.dataService.getEcoKnowledgeList();
      }
      
      // 如果没有数据，添加更多示例数据
      if (this.knowledgeList.length === 0) {
        await this.addMoreSampleKnowledge()
        this.knowledgeList = await this.dataService.getEcoKnowledgeList()
      }
    } catch (error) {
      console.error('加载环保知识失败:', error)
      promptAction.showToast({ message: '加载失败，请重试' })
    } finally {
      this.isLoading = false;
    }
  }

  private async addMoreSampleKnowledge() {
    const moreKnowledge = [
      new EcoKnowledge(
        '如何正确进行垃圾分类',
        '垃圾分类是环保的重要一环。可回收物包括废纸、废塑料、废金属、废玻璃等；有害垃圾包括废电池、废灯管、废药品等；湿垃圾是易腐烂的生物质废料；干垃圾是除上述三类之外的其他垃圾。正确分类可以提高资源回收利用率，减少环境污染。',
        '垃圾分类',
        '环保部门'
      ),
      new EcoKnowledge(
        '家庭节能减排小妙招',
        '1.使用LED灯泡，比传统白炽灯节能80%；2.合理设置空调温度，夏季26℃，冬季20℃；3.及时关闭不用的电器；4.使用节能家电；5.充分利用自然光；6.定期清洁空调滤网。这些小习惯能显著降低家庭碳排放。',
        '节能减排',
        '节能协会'
      ),
      new EcoKnowledge(
        '绿色出行的多种选择',
        '绿色出行不仅环保，还有益健康。步行适合短距离出行，既锻炼身体又零排放；自行车出行灵活便捷，适合中短距离；公共交通人均碳排放低；电动汽车比燃油车减排50%以上；拼车出行可以减少道路拥堵和排放。',
        '低碳出行',
        '交通运输部'
      ),
      new EcoKnowledge(
        '塑料污染与减塑行动',
        '塑料污染已成为全球环境问题。减塑从日常做起：使用可重复购物袋；选择玻璃或不锈钢水瓶；避免一次性餐具；选择包装简单的商品；参与塑料回收；支持可降解材料。每个人的小行动汇聚成保护地球的大力量。',
        '绿色生活',
        '环保组织'
      ),
      new EcoKnowledge(
        '城市绿化的重要意义',
        '城市绿化不仅美化环境，更有重要的生态功能。树木能吸收二氧化碳，释放氧气；调节城市温度，缓解热岛效应；净化空气，吸附粉尘；涵养水源，防止水土流失；为野生动物提供栖息地。每棵树都是城市的绿色卫士。',
        '绿色生活',
        '城市规划局'
      )
    ]

    for (const knowledge of moreKnowledge) {
      await this.dataService.saveEcoKnowledge(knowledge)
    }
  }

  private getFilteredKnowledge(): EcoKnowledge[] {
    let filtered = this.knowledgeList

    // 按分类过滤
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(item => item.category === this.selectedCategory);
    }

    // 按关键词过滤
    if (this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.trim().toLowerCase()
      filtered = filtered.filter(item => 
        item.title.toLowerCase().includes(keyword) || 
        item.content.toLowerCase().includes(keyword)
      )
    }

    // 按发布时间排序（最新的在前）
    return filtered.sort((a, b) => b.publishDate.getTime() - a.publishDate.getTime())
  }

  private filterKnowledge() {
    // 触发重新渲染
    this.knowledgeList = [...this.knowledgeList]
  }


  private viewKnowledgeDetail(knowledge: EcoKnowledge) {
    // 增加浏览量
    knowledge.addView();

    // 保存浏览量增加
    this.dataService.saveEcoKnowledge(knowledge).then(() => {
      // 找到最新数据中的知识条目
      const index = this.knowledgeList.findIndex(k => k.id === knowledge.id);
      if (index !== -1) {
        // 更新本地列表中的数据
        this.knowledgeList[index] = knowledge;
        // 触发UI更新
        this.knowledgeList = [...this.knowledgeList];
      }

      // 显示详细内容
      promptAction.showDialog({
        title: knowledge.title,
        message: knowledge.content,
        buttons: [
          {
            text: '点赞',
            color: '#4CAF50'
          },
          {
            text: '关闭',
            color: '#666'
          }
        ]
      }).then((result) => {
        if (result.index === 0) {
          // 点赞
          knowledge.addLike();
          this.dataService.saveEcoKnowledge(knowledge).then(() => {
            // 更新本地列表中的数据
            const updatedIndex = this.knowledgeList.findIndex(k => k.id === knowledge.id);
            if (updatedIndex !== -1) {
              this.knowledgeList[updatedIndex] = knowledge;
              // 触发UI更新
              this.knowledgeList = [...this.knowledgeList];
            }
            promptAction.showToast({ message: '点赞成功！' });
          });
        }
      });
    });
  }

  private formatDate(date: Date): string {
    const now = new Date()
    const diff = now.getTime() - date.getTime()
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))
    
    if (days === 0) {
      return '今天'
    } else if (days === 1) {
      return '昨天'
    } else if (days < 7) {
      return `${days}天前`
    } else {
      return `${date.getMonth() + 1}月${date.getDate()}日`
    }
  }
}