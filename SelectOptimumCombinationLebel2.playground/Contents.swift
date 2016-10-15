//: Playground - noun: a place where people can play

// CTOからの挑戦状 of VOYAGE GROUP - Level2
// 購入する商品のリストと手持ちの割引クーポンを渡すと利用すべき割引クーポンを教えてくれるツールを作成

import UIKit

// Stringを拡張
extension String {
    var upperCamelCase: String {
        
        let startIndex = self.startIndex
        let secondindex = self.index(after: startIndex)
        
        let first = self.substring(with: startIndex..<secondindex)
        let other = self.substring(from: secondindex)
        
        return first.uppercased() + other
    }
}


// MARK: - オーダーに関する処理と商品情報

protocol Food {
    var name: String { get }
    var price: Int { get }
}


class Pizza: Food {
    var type: PizzaType
    var size: PizzaSize
    
    var name: String {
        return self.type.rawValue.upperCamelCase
    }
    
    var price: Int {
        switch (type, size) {
        case (.genovese, .middle): return 1000
        case (.genovese, .large): return 1400
        case (.margherita, .middle): return 1200
        case (.margherita, .large): return 1800
        }
    }
    
    init(type: PizzaType, size: PizzaSize) {
        self.type = type
        self.size = size
    }
    
    enum PizzaType: String {
        case genovese, margherita
    }
    
    enum PizzaSize: String {
        case middle, large
    }
    
}


class SideMenu: Food {
    var type: SideMenuType
    
    var price: Int {
        switch type {
        case .frenchFries: return 400
        case .greenSalad: return 500
        case .caesarSalad: return 600
        }
    }
    
    var name: String {
        return self.type.rawValue.upperCamelCase
    }
    
    init(type: SideMenuType) {
        self.type = type
    }
    
    enum SideMenuType: String {
        case frenchFries, greenSalad, caesarSalad
    }
    
}


class Order {
    fileprivate var orders: [Food] = []
    
    // 商品の注文をする
    func requestOrder(food: Food, number: Int) {
        for _ in 0..<number {
            orders.append(food)
        }
    }
    
    // オーダーの合計金額を返すメソッド
    fileprivate var totalFee: Int {
        return orders.reduce(0) { total, food in
            total + food.price
        }
    }
    
    // オーダーをリストアップするメソッド
    fileprivate func orderCheck() {
        for i in orders {
            print("\(i.name)")
        }
    }
    
}



// MARK: - クーポンの情報

struct Coupons {
    fileprivate var numbers: [Int]
    
    init() {
        numbers = Array(repeating: 0, count: Coupon.count)
    }
    
    init(coupon1: Int, coupon2: Int, coupon3: Int, pizzaCoupon: Int) {
        numbers = [coupon1, coupon2, coupon3, pizzaCoupon]
    }
    
    // クーポンの枚数を変更する
    fileprivate mutating func alterValue(typeOf coupon: Coupon, value: Int) {
        numbers[coupon.hashValue] = value
    }
    
    // 指定したクーポンの枚数を返す
    fileprivate func getNumber(of coupon: Coupon) -> Int {
        return numbers[coupon.hashValue]
    }
    
    // クーポンの合計枚数を返す
    fileprivate var countAll: Int {
        return numbers.reduce(0) { count, number in
            // (0)はcountの初期値
            // countに要素を加えた結果を新たにcountとする
            count + number
        }
    }
    
    // クーポンの合計値引き額を返す
    fileprivate var totalDiscount: Int {
        var total = 0
        for i in 0..<Coupon.count {
            let discount = Coupon.init(rawValue: i)?.discountValue
            total += discount! * numbers[i]
        }
        return total
    }
    
}

fileprivate enum Coupon: Int {
    case coupon1, coupon2, coupon3, pizzaCoupon
    
    // 要素数を返す -> Coupon: Int
    fileprivate static var count: Int {
        var i = 0
        // nilになるまでインスタンスを生成
        while let _ = Coupon(rawValue: i) {
            i += 1
        }
        return i
    }
    
    fileprivate var discountValue: Int {
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
    
    fileprivate var limitNumber: Int {
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
    
    private let myOrder: Order
    private let myCoupons: Coupons
    
    // オーダーの合計金額
    private let amount: Int
    // 支払金額
    private var pay: Int
    // 合計割引額
    private var discount = 0
    // 使用したクーポン組み合わせ
    private var selectedCoupons: Coupons
    
    
    init(order: Order, coupons: Coupons) {
        myOrder = order
        myCoupons = coupons
        
        amount = order.totalFee
        pay = amount
        selectedCoupons = Coupons()     // [0, 0, 0, 0]
    }
    
    // クーポン再選択時の初期化用メソッド
    private func cancelSelect() {
        pay = amount
        selectedCoupons = Coupons()
    }
    
    // あるクーポンの組み合わせをもとにシミュレーション（デタラメな値を入れないように）
    private func simulateOf(coupons: Coupons) {
        discount = coupons.totalDiscount
        pay = amount - discount
        selectedCoupons = coupons
    }
    
    // 最適なクーポンの組み合わせを返す
    var selectCoupons: [Int] {
        
        if !isCanUseCoupons {
            let noCoupon = Array(repeating: 0, count: Coupon.count)
            return noCoupon
        }
        
        // ピザクーポンが使えるなら
        if isCanUsePizzaCoupon {
            // 使った場合と使わなかった場合で支払額が低い方を採用する
            useAllCoupon()
            let selectedCoupons1 = selectedCoupons
            
            useOnlyNormalCoupon()
            let selectedCoupons2 = selectedCoupons
            
            simulateOf(coupons: compareCoupons(coupons1: selectedCoupons1, coupons2: selectedCoupons2))
            
        } else {
            // ピザクーポンが使えない時
            useOnlyNormalCoupon()
        }
        
        return selectedCoupons.numbers
    }
    
    // 使用するクーポンと持っている枚数を渡して値引きするメソッド
    private func useCoupon(typeOf coupon: Coupon, number: Int) {
        
        var couponCount = number
        let value = coupon.discountValue
        
        if number != 0 {
            // クーポンがなくなるか、支払額が値引額を下回るか、制限枚数使用するまでクーポンを使う
            while (couponCount != 0) && (pay >= value) && ((number - couponCount) != coupon.discountValue) {
                // クーポンが使用できる条件を満たした上で、使用した場合のpayとdiscountを比較する
                if (pay - value) >= (discount + value) {
                    // 使用可能
                    pay -= value
                    discount += value
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
    private var isCanUseCoupons: Bool {
        // 1000円以下はクーポン対象外
        if amount <= 1000 {
            return false
        } else {
            return true
        }
    }
    
    // ピザクーポンが使えるかどうかを返す
    private var isCanUsePizzaCoupon: Bool {
        for food in myOrder.orders {
            // 型判定
            // どっちでもできる
//            if food is Pizza {
//                return true
//            }
            
            // foodがPizzaにキャストできれば変数のの中に格納される
            if let _ = food as? Pizza {
                return true
            }
        }
        return false
    }
    
    // 使用するクーポンの合計枚数を得る
    private var countCoupons: Int {
        return selectedCoupons.numbers.reduce(0) { count, number in
            // (0)はcountの初期値
            // countに要素を加えた結果を新たにcountとする
            count + number
        }
    }
    
    // 基本クーポンのみを使用
    private func useOnlyNormalCoupon() {
        cancelSelect()
        useCoupon(typeOf: .coupon1, number: myCoupons.getNumber(of: .coupon1))
        useCoupon(typeOf: .coupon2, number: myCoupons.getNumber(of: .coupon2))
        useCoupon(typeOf: .coupon3, number: myCoupons.getNumber(of: .coupon3))
//        self.selectedCoupons.alterValue(typeOf: .pizzaCoupon, value: 0)
    }
    
    // 全てのクーポンを使用
    private func useAllCoupon() {
        cancelSelect()
        // 優先的にピザクーポンを使う
        useCoupon(typeOf: .pizzaCoupon, number: myCoupons.getNumber(of: .pizzaCoupon))
        useCoupon(typeOf: .coupon1, number: myCoupons.getNumber(of: .coupon1))
        useCoupon(typeOf: .coupon2, number: myCoupons.getNumber(of: .coupon2))
        useCoupon(typeOf: .coupon3, number: myCoupons.getNumber(of: .coupon3))
    }
    
    // 2つのクーポンの組み合わせのうち(値引額->大)かつ(枚数->少)の方を返す
    private func compareCoupons(coupons1 former: Coupons, coupons2 later: Coupons) -> Coupons {
        
        if former.totalDiscount > later.totalDiscount {
            return former
        }
        else if former.totalDiscount == later.totalDiscount {
            // 支払額が同じであれば、合計枚数が少ない方を採用する
            if former.countAll < later.countAll {
                return former
            }
        }
        return later
    }
    
}



// アクセスレベルを意識して、最低限使う機能のみでテスト
let myOrder = Order()

myOrder.requestOrder(food: Pizza(type: .genovese, size: .large), number: 1)
myOrder.requestOrder(food: Pizza(type: .margherita, size: .middle), number: 2)
myOrder.requestOrder(food: SideMenu(type: .frenchFries), number: 2)

let myCoupons = Coupons(coupon1: 3, coupon2: 3, coupon3: 4, pizzaCoupon: 2)

let mySelect = SelectOptimumCombination(order: myOrder, coupons: myCoupons)
mySelect.selectCoupons


















