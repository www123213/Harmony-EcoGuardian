// 碳排放因子接口
interface CarbonFactors {
  walk_1km: number;
  bike_1km: number;
  public_transport_1km: number;
  carpool_1km: number;
  save_water_1L: number;
  shower_reduce_1min: number;
  save_electricity_1kwh: number;
  led_bulb: number;
  unplug_device: number;
  recycle_paper_1kg: number;
  recycle_plastic_1kg: number;
  recycle_glass_1kg: number;
  recycle_metal_1kg: number;
  compost_1kg: number;
  reusable_bag: number;
  reusable_bottle: number;
  local_food_1kg: number;
  vegetarian_meal: number;
  plant_tree: number;
  plant_flower: number;
  clean_beach_1hour: number;
  clean_park_1hour: number;
  environmental_education: number;
}

// 环保行为接口
interface EcoAction {
  type: string;
  quantity: number;
}

// 行为描述接口
interface ActionDescriptions {
  walk_1km: string;
  bike_1km: string;
  public_transport_1km: string;
  carpool_1km: string;
  save_water_1L: string;
  shower_reduce_1min: string;
  save_electricity_1kwh: string;
  led_bulb: string;
  unplug_device: string;
  recycle_paper_1kg: string;
  recycle_plastic_1kg: string;
  recycle_glass_1kg: string;
  recycle_metal_1kg: string;
  compost_1kg: string;
  reusable_bag: string;
  reusable_bottle: string;
  local_food_1kg: string;
  vegetarian_meal: string;
  plant_tree: string;
  plant_flower: string;
  clean_beach_1hour: string;
  clean_park_1hour: string;
  environmental_education: string;
}

// 减排等级接口
interface ReductionLevel {
  level: string;
  title: string;
  nextTarget: number;
}

// 碳足迹计算器
export class CarbonCalculator {
  private static instance: CarbonCalculator;

  private constructor() {}

  public static getInstance(): CarbonCalculator {
    if (!CarbonCalculator.instance) {
      CarbonCalculator.instance = new CarbonCalculator();
    }
    return CarbonCalculator.instance;
  }

  // 环保行为类型和对应的减排系数（单位：kg CO2）
  private readonly carbonFactors: CarbonFactors = {
    // 交通出行
    'walk_1km': 0.2,           // 步行1公里替代开车
    'bike_1km': 0.2,           // 骑行1公里替代开车
    'public_transport_1km': 0.1, // 公共交通1公里替代开车
    'carpool_1km': 0.1,        // 拼车1公里
    
    // 节约用水
    'save_water_1L': 0.0003,   // 节约1升水
    'shower_reduce_1min': 0.5,  // 减少1分钟淋浴时间
    
    // 节约用电
    'save_electricity_1kwh': 0.785, // 节约1度电
    'led_bulb': 0.04,          // 使用LED灯泡（每天）
    'unplug_device': 0.1,      // 拔掉待机设备插头（每天）
    
    // 垃圾分类和回收
    'recycle_paper_1kg': 1.7,  // 回收1公斤纸张
    'recycle_plastic_1kg': 2.0, // 回收1公斤塑料
    'recycle_glass_1kg': 0.3,  // 回收1公斤玻璃
    'recycle_metal_1kg': 1.5,  // 回收1公斤金属
    'compost_1kg': 0.5,        // 堆肥1公斤有机垃圾
    
    // 绿色消费
    'reusable_bag': 0.04,      // 使用环保袋（每次）
    'reusable_bottle': 0.1,    // 使用可重复水瓶（每次）
    'local_food_1kg': 0.5,     // 购买本地食品1公斤
    'vegetarian_meal': 2.5,    // 素食一餐
    
    // 植树造林
    'plant_tree': 22.0,        // 种植一棵树（年减排量）
    'plant_flower': 0.1,       // 种植花草（每株）
    
    // 其他环保行为
    'clean_beach_1hour': 1.0,  // 海滩清理1小时
    'clean_park_1hour': 0.8,   // 公园清理1小时
    'environmental_education': 0.5, // 参与环保教育活动
  };

  // 计算单个环保行为的减排量
  calculateSingleAction(actionType: string, quantity: number = 1): number {
    const factor: number | undefined = this.getCarbonFactor(actionType);
    if (factor === undefined) {
      console.warn(`未知的环保行为类型: ${actionType}`);
      return 0;
    }
    return factor * quantity;
  }

  // 计算多个环保行为的总减排量
  calculateMultipleActions(actions: EcoAction[]): number {
    return actions.reduce((total, action) => {
      return total + this.calculateSingleAction(action.type, action.quantity);
    }, 0);
  }

  // 根据环保行为类型获取建议积分
  getSuggestedPoints(actionType: string, quantity: number = 1): number {
    const carbonReduction = this.calculateSingleAction(actionType, quantity);
    // 积分 = 减排量 * 10（可调整系数）
    return Math.round(carbonReduction * 10);
  }

  // 获取所有支持的环保行为类型
  getSupportedActionTypes(): string[] {
    return Object.keys(this.carbonFactors);
  }

  // 获取环保行为的中文描述
  getActionDescription(actionType: string): string {
    const descriptions: ActionDescriptions = {
      'walk_1km': '步行1公里（替代开车）',
      'bike_1km': '骑行1公里（替代开车）',
      'public_transport_1km': '乘坐公共交通1公里',
      'carpool_1km': '拼车出行1公里',
      'save_water_1L': '节约用水1升',
      'shower_reduce_1min': '减少淋浴时间1分钟',
      'save_electricity_1kwh': '节约用电1度',
      'led_bulb': '使用LED灯泡（一天）',
      'unplug_device': '拔掉待机设备插头（一天）',
      'recycle_paper_1kg': '回收纸张1公斤',
      'recycle_plastic_1kg': '回收塑料1公斤',
      'recycle_glass_1kg': '回收玻璃1公斤',
      'recycle_metal_1kg': '回收金属1公斤',
      'compost_1kg': '堆肥有机垃圾1公斤',
      'reusable_bag': '使用环保袋（一次）',
      'reusable_bottle': '使用可重复水瓶（一次）',
      'local_food_1kg': '购买本地食品1公斤',
      'vegetarian_meal': '素食一餐',
      'plant_tree': '种植一棵树',
      'plant_flower': '种植花草一株',
      'clean_beach_1hour': '海滩清理1小时',
      'clean_park_1hour': '公园清理1小时',
      'environmental_education': '参与环保教育活动'
    };
    switch (actionType) {
      case 'walk_1km': return descriptions.walk_1km;
      case 'bike_1km': return descriptions.bike_1km;
      case 'public_transport_1km': return descriptions.public_transport_1km;
      case 'carpool_1km': return descriptions.carpool_1km;
      case 'save_water_1L': return descriptions.save_water_1L;
      case 'shower_reduce_1min': return descriptions.shower_reduce_1min;
      case 'save_electricity_1kwh': return descriptions.save_electricity_1kwh;
      case 'led_bulb': return descriptions.led_bulb;
      case 'unplug_device': return descriptions.unplug_device;
      case 'recycle_paper_1kg': return descriptions.recycle_paper_1kg;
      case 'recycle_plastic_1kg': return descriptions.recycle_plastic_1kg;
      case 'recycle_glass_1kg': return descriptions.recycle_glass_1kg;
      case 'recycle_metal_1kg': return descriptions.recycle_metal_1kg;
      case 'compost_1kg': return descriptions.compost_1kg;
      case 'reusable_bag': return descriptions.reusable_bag;
      case 'reusable_bottle': return descriptions.reusable_bottle;
      case 'local_food_1kg': return descriptions.local_food_1kg;
      case 'vegetarian_meal': return descriptions.vegetarian_meal;
      case 'plant_tree': return descriptions.plant_tree;
      case 'plant_flower': return descriptions.plant_flower;
      case 'clean_beach_1hour': return descriptions.clean_beach_1hour;
      case 'clean_park_1hour': return descriptions.clean_park_1hour;
      case 'environmental_education': return descriptions.environmental_education;
      default: return actionType;
    }
  }

  // 获取环保行为分类
  getActionCategory(actionType: string): string {
    if (actionType.includes('walk') || actionType.includes('bike') || actionType.includes('transport') || actionType.includes('carpool')) {
      return '绿色出行';
    }
    if (actionType.includes('water') || actionType.includes('shower')) {
      return '节约用水';
    }
    if (actionType.includes('electricity') || actionType.includes('led') || actionType.includes('unplug')) {
      return '节约用电';
    }
    if (actionType.includes('recycle') || actionType.includes('compost')) {
      return '垃圾分类回收';
    }
    if (actionType.includes('bag') || actionType.includes('bottle') || actionType.includes('food') || actionType.includes('meal')) {
      return '绿色消费';
    }
    if (actionType.includes('plant') || actionType.includes('tree')) {
      return '植树造林';
    }
    if (actionType.includes('clean')) {
      return '环境清理';
    }
    return '其他环保行为';
  }

  // 计算年度减排目标完成度
  calculateYearlyProgress(currentReduction: number, targetReduction: number = 1000): number {
    return Math.min((currentReduction / targetReduction) * 100, 100);
  }

  // 获取减排量等级
  getReductionLevel(totalReduction: number): ReductionLevel {
    if (totalReduction < 10) {
      return { level: '环保新手', title: '刚刚开始环保之旅', nextTarget: 10 } as ReductionLevel;
    } else if (totalReduction < 50) {
      return { level: '环保达人', title: '积极参与环保行动', nextTarget: 50 } as ReductionLevel;
    } else if (totalReduction < 100) {
      return { level: '环保达人', title: '积极参与环保行动', nextTarget: 100 } as ReductionLevel;
    } else if (totalReduction < 500) {
      return { level: '环保专家', title: '环保行为已成习惯', nextTarget: 500 } as ReductionLevel;
    } else if (totalReduction < 1000) {
      return { level: '环保大使', title: '环保行动的引领者', nextTarget: 1000 } as ReductionLevel;
    } else {
      return { level: '环保卫士', title: '地球环境的守护者', nextTarget: 2000 } as ReductionLevel;
    }
  }

  // 格式化减排量显示
  formatCarbonReduction(reduction: number): string {
    if (reduction < 1) {
      return `${(reduction * 1000).toFixed(0)}g CO₂`;
    } else if (reduction < 1000) {
      return `${reduction.toFixed(2)}kg CO₂`;
    } else {
      return `${(reduction / 1000).toFixed(2)}t CO₂`;
    }
  }

  private getCarbonFactor(actionType: string): number | undefined {
    switch (actionType) {
      case 'walk_1km': return this.carbonFactors.walk_1km;
      case 'bike_1km': return this.carbonFactors.bike_1km;
      case 'public_transport_1km': return this.carbonFactors.public_transport_1km;
      case 'carpool_1km': return this.carbonFactors.carpool_1km;
      case 'save_water_1L': return this.carbonFactors.save_water_1L;
      case 'shower_reduce_1min': return this.carbonFactors.shower_reduce_1min;
      case 'save_electricity_1kwh': return this.carbonFactors.save_electricity_1kwh;
      case 'led_bulb': return this.carbonFactors.led_bulb;
      case 'unplug_device': return this.carbonFactors.unplug_device;
      case 'recycle_paper_1kg': return this.carbonFactors.recycle_paper_1kg;
      case 'recycle_plastic_1kg': return this.carbonFactors.recycle_plastic_1kg;
      case 'recycle_glass_1kg': return this.carbonFactors.recycle_glass_1kg;
      case 'recycle_metal_1kg': return this.carbonFactors.recycle_metal_1kg;
      case 'compost_1kg': return this.carbonFactors.compost_1kg;
      case 'reusable_bag': return this.carbonFactors.reusable_bag;
      case 'reusable_bottle': return this.carbonFactors.reusable_bottle;
      case 'local_food_1kg': return this.carbonFactors.local_food_1kg;
      case 'vegetarian_meal': return this.carbonFactors.vegetarian_meal;
      case 'plant_tree': return this.carbonFactors.plant_tree;
      case 'plant_flower': return this.carbonFactors.plant_flower;
      case 'clean_beach_1hour': return this.carbonFactors.clean_beach_1hour;
      case 'clean_park_1hour': return this.carbonFactors.clean_park_1hour;
      case 'environmental_education': return this.carbonFactors.environmental_education;
      default: return undefined;
    }
  }
}