//: Playground - noun: a place where people can play

// CTOからの挑戦状 of VOYAGE GROUP - Level2
// 購入する商品のリストと手持ちの割引クーポンを渡すと利用すべき割引クーポンを教えてくれるツールを作成

import UIKit

// MARK: - オーダーに関する処理と商品情報

struct Menu {
    var type: Food
    var detail: String
    var price: Int
    var number: Int
    
    // オーダーがピザの場合
    init(name: Pizza, size: PizzaSize, number: Int) {
        self.type = Food.pizza
        self.number = number
        
        self.detail = name.getString() + " " + size.getString()
        
        self.price = name.getPrice(size: size)
    }
    
    // オーダーがサイドメニューの場合
    init(name: SideMenu, number: Int) {
        self.type = Food.sideMenu
        self.number = number
        
        self.detail = name.getString()
        
        self.price = name.getPrice()
    }
    
}


enum Food {
    case pizza
    case sideMenu
}


enum PizzaSize {
    case middle
    case large
    
    func getString() -> String {
        switch self {
        case .middle:
            return "Middle"
        case .large:
            return "Large"
        }
    }
    
}


enum Pizza {
    case genovese
    case margherita
    
    func getPrice(size: PizzaSize) -> Int {
        switch self {
        case .genovese:
            
            switch size {
            case .middle:
                return 1000
            case .large:
                return 1400
            }
            
        case .margherita:
            switch size {
            case .middle:
                return 1200
            case .large:
                return 1800
            }
        }
    }
    
    func getString() -> String {
        switch self {
        case .genovese:
            return "Genovese"
        case .margherita:
            return "Margherita"
        }
    }
    
}


enum SideMenu {
    case frenchFries
    case greenSalad
    case caesarSalad
    
    func getPrice() -> Int {
        switch self {
        case .frenchFries:
            return 400
        case .greenSalad:
            return 500
        case .caesarSalad:
            return 600
        }
    }
    
    func getString() -> String {
        switch self {
        case .frenchFries:
            return "FrenchFries"
        case .greenSalad:
            return "GreenSalad"
        case .caesarSalad:
            return "CaesarSalad"
        }
    }
}


class Order {
    var orderArray: [Menu] = []
    
    // ピザをオーダーを追加するメソッド
    func PizzaOrder(name: Pizza, size: PizzaSize, number: Int) {
        let order = Menu(name: name, size: size, number: number)
        orderArray.append(order)
    }
    
    // サイドメニューをオーダーするメソッド
    func SideMenuOrder(name: SideMenu, number: Int) {
        let order = Menu(name: name, number: number)
        orderArray.append(order)
    }
    
    // オーダーの合計金額を返すメソッド
    func getTotalFee() -> Int {
        
        var total: Int = 0
        
        for i in orderArray {
            total += i.price * i.number
        }
        
        return total
    }
    
    // オーダーをリストアップするメソッド
    func orderCheck() {
        
        for i in orderArray {
            print("\(i.detail) ×\(i.number)")
        }
        
    }
    
}


// MARK: - クーポンの情報

struct Coupons {
    var numberArray: [Int]
    
    init() {
        self.numberArray = Array(repeating: 0, count: Coupon.count)
    }
    
    init(coupon1: Int, coupon2: Int, coupon3: Int, pizzaCoupon: Int) {
        self.numberArray = [coupon1, coupon2, coupon3, pizzaCoupon]
    }
    
    // クーポンの枚数を変更する
    mutating func alterValue(typeOf coupon: Coupon, value: Int) {
        self.numberArray[coupon.hashValue] = value
    }
    
    // 指定したクーポンの枚数を返す
    func getNumber(_ coupon: Coupon) -> Int {
        return self.numberArray[coupon.hashValue]
    }
    
    // クーポンの合計枚数を返す
    func countAll() -> Int {
        var count = 0
        for i in self.numberArray {
            count += i
        }
        return count
    }
    
    // クーポンの合計値引き額を返す
    func totalDiscount() -> Int {
        var total = 0
        for i in 0..<Coupon.count {
            let discount = Coupon.init(rawValue: i)?.getDiscountValue()
            total += discount! * self.numberArray[i]
        }
        return total
    }
    
}

enum Coupon: Int {
    case coupon1
    case coupon2
    case coupon3
    case pizzaCoupon
    
    // 要素数を返す -> Coupon: Int
    static var count: Int {
        var i = 0
        // nilになるまでインスタンスを生成
        while let _ = Coupon(rawValue: i) {
            i += 1
        }
        return i
    }
    
    func getDiscountValue() -> Int {
        switch self {
        case .coupon1:
            return 500
        case .coupon2:
            return 200
        case .coupon3:
            return 100
        case .pizzaCoupon:
            return 400
        }
    }
    
    func getLimitNumber() -> Int {
        switch self {
        case .coupon1:
            return 2
        case .coupon2:
            return 2
        case .coupon3:
            return 3
        case .pizzaCoupon:
            return 1
        }
    }
    
}


// MARK: - オーダー内容と所持クーポンからクーポンの使用を提案

class SelectOptimumCombination {
    
    let myOrder: Order
    let myCoupons: Coupons
    
    // オーダーの合計金額
    let amount: Int
    // 支払金額
    var pay: Int
    // 合計割引額
    var discount: Int
    // 使用したクーポン組み合わせ
    var selectedCoupons: Coupons
    
    
    init(order: Order, coupons: Coupons) {
        self.myOrder = order
        self.myCoupons = coupons
        
        self.amount = order.getTotalFee()
        self.pay = self.amount
        self.discount = 0
        self.selectedCoupons = Coupons()     // [0, 0, 0, 0]
    }
    
    // クーポン再選択時の初期化用メソッド
    func cancelSelect() {
        self.pay = self.amount
        self.discount = 0
        self.selectedCoupons = Coupons()
    }
    
    // あるクーポンの組み合わせをもとにシミュレーション（デタラメな値を入れないように）
    private func simulateOf(coupons: Coupons) {
        self.discount = coupons.totalDiscount()
        self.pay = self.amount - self.discount
        self.selectedCoupons = coupons
    }
    
    // 最適なクーポンの組み合わせを返す
    func selectCoupons() -> [Int] {
        
        if isCanUseCoupons() != true {
            let noCoupon = Array(repeating: 0, count: Coupon.count)
            return noCoupon
        }
        
        // ピザクーポンが使えるなら
        if isCanUsePizzaCoupon() {
            // 使った場合と使わなかった場合で支払額が低い方を採用する
            useAllCoupon()
            let selectedCoupons1 = self.selectedCoupons
            
            useOnlyNormalCoupon()
            let selectedCoupons2 = self.selectedCoupons
            
            simulateOf(coupons: compareCoupons(coupons1: selectedCoupons1, coupons2: selectedCoupons2))
            
        } else {
            // ピザクーポンが使えない時
            useOnlyNormalCoupon()
        }
        
        return self.selectedCoupons.numberArray
    }
    
    // 使用するクーポンと持っている枚数を渡して値引きするメソッド
    func useCoupon(typeOf coupon: Coupon, number: Int) {
        
        var couponCount = number
        let value = coupon.getDiscountValue()
        
        if number != 0 {
            // クーポンがなくなるか、支払額が値引額を下回るか、制限枚数使用するまでクーポンを使う
            while (couponCount != 0) && (self.pay >= value) && ((number - couponCount) != coupon.getLimitNumber()) {
                // クーポンが使用できる条件を満たした上で、使用した場合のpayとdiscountを比較する
                if (self.pay - value) >= (self.discount + value) {
                    // 使用可能
                    self.pay -= value
                    self.discount += value
                    couponCount -= 1
                } else {
                    // 使用不可
                    break
                }
            }
        }
        
        let useNum = number - couponCount
        self.selectedCoupons.alterValue(typeOf: coupon, value: useNum)
    }
    
    // クーポンが使えるかどうか
    func isCanUseCoupons() -> Bool {
        // 1000円以下はクーポン対象外
        if self.amount <= 1000 {
            return false
        } else {
            return true
        }
    }
    
    // ピザクーポンが使えるかどうかを返す
    func isCanUsePizzaCoupon() -> Bool {
        for menu in self.myOrder.orderArray {
            if menu.type == Food.pizza {
                return true
            }
        }
        return false
    }
    
    // 使用するクーポンの合計枚数を得る
    func countCoupons() -> Int {
        var count = 0
        for i in self.selectedCoupons.numberArray {
            count += i
        }
        return count
    }
    
    // 基本クーポンのみを使用
    func useOnlyNormalCoupon() {
        cancelSelect()
        useCoupon(typeOf: .coupon1, number: myCoupons.getNumber(.coupon1))
        useCoupon(typeOf: .coupon2, number: myCoupons.getNumber(.coupon2))
        useCoupon(typeOf: .coupon3, number: myCoupons.getNumber(.coupon3))
//        self.selectedCoupons.alterValue(typeOf: .pizzaCoupon, value: 0)
    }
    
    // 全てのクーポンを使用
    func useAllCoupon() {
        cancelSelect()
        // 優先的にピザクーポンを使う
        useCoupon(typeOf: .pizzaCoupon, number: myCoupons.getNumber(.pizzaCoupon))
        useCoupon(typeOf: .coupon1, number: myCoupons.getNumber(.coupon1))
        useCoupon(typeOf: .coupon2, number: myCoupons.getNumber(.coupon2))
        useCoupon(typeOf: .coupon3, number: myCoupons.getNumber(.coupon3))
    }
    
    // 2つのクーポンの組み合わせのうち(値引額->大)かつ(枚数->少)の方を返す
    func compareCoupons(coupons1 former: Coupons, coupons2 later: Coupons) -> Coupons {
        
        if former.totalDiscount() > later.totalDiscount() {
            return former
        }
        else if former.totalDiscount() == later.totalDiscount() {
            // 支払額が同じであれば、合計枚数が少ない方を採用する
            if former.countAll() < later.countAll() {
                return former
            }
        }
        return later
    }
    
}


// テストコード

let myOrder = Order()
myOrder.PizzaOrder(name: .genovese, size: .large, number: 1)
myOrder.SideMenuOrder(name: .frenchFries, number: 1)
//myOrder.SideMenuOrder(name: .GreenSalad, number: 1)
myOrder.SideMenuOrder(name: .caesarSalad, number: 1)
myOrder.PizzaOrder(name: .margherita, size: .middle, number: 1)

myOrder.orderCheck()
myOrder.getTotalFee()

let myCoupons = Coupons(coupon1: 3, coupon2: 3, coupon3: 4, pizzaCoupon: 2)

let mySelect = SelectOptimumCombination(order: myOrder, coupons: myCoupons)
//mySelect.useCoupon(typeOf: .coupon1, number: 3)
mySelect.selectCoupons()
//mySelect.useCoupon(typeOf: .coupon2, number: 3)
//mySelect.useOnlyNormalCoupon()
//mySelect.useAllCoupon()
print("支払額: \(mySelect.pay)")
print("値引額: \(mySelect.discount)")



























