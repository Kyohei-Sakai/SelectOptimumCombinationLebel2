//: Playground - noun: a place where people can play

// CTOからの挑戦状 of VOYAGE GROUP - Level2
// 購入する商品のリストと手持ちの割引クーポンを渡すと利用すべき割引クーポンを教えてくれるツールを作成

import UIKit

// MARK: - オーダーに関する処理と商品情報

fileprivate struct Menu {
    fileprivate var type: Food
    fileprivate var detail: String
    fileprivate var price: Int
    fileprivate var number: Int
    
    // オーダーがピザの場合
    init(name: Pizza, size: PizzaSize, number: Int) {
        type = Food.pizza
        self.number = number
        
        detail = name.getString() + " " + size.getString()
        
        price = name.getPrice(size: size)
    }
    
    // オーダーがサイドメニューの場合
    init(name: SideMenu, number: Int) {
        type = Food.sideMenu
        self.number = number
        
        detail = name.getString()
        
        price = name.getPrice()
    }
    
}


fileprivate enum Food {
    case pizza, sideMenu
}


enum PizzaSize {
    case middle, large
    
    fileprivate func getString() -> String {
        switch self {
        case .middle:
            return "Middle"
        case .large:
            return "Large"
        }
    }
    
}


enum Pizza {
    case genovese, margherita
    
    fileprivate func getPrice(size: PizzaSize) -> Int {
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
    
    fileprivate func getString() -> String {
        switch self {
        case .genovese:
            return "Genovese"
        case .margherita:
            return "Margherita"
        }
    }
    
}


enum SideMenu {
    case frenchFries, greenSalad, caesarSalad
    
    fileprivate func getPrice() -> Int {
        switch self {
        case .frenchFries:
            return 400
        case .greenSalad:
            return 500
        case .caesarSalad:
            return 600
        }
    }
    
    fileprivate func getString() -> String {
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
    fileprivate var orderArray: [Menu] = []
    
    // ピザをオーダーを追加するメソッド
    func pizzaOrder(name: Pizza, size: PizzaSize, number: Int) {
        let order = Menu(name: name, size: size, number: number)
        orderArray.append(order)
    }
    
    // サイドメニューをオーダーするメソッド
    func sideMenuOrder(name: SideMenu, number: Int) {
        let order = Menu(name: name, number: number)
        orderArray.append(order)
    }
    
    // オーダーの合計金額を返すメソッド
    fileprivate func getTotalFee() -> Int {
        
        var total: Int = 0
        
        for i in orderArray {
            total += i.price * i.number
        }
        
        return total
    }
    
    // オーダーをリストアップするメソッド
    fileprivate func orderCheck() {
        
        for i in orderArray {
            print("\(i.detail) ×\(i.number)")
        }
        
    }
    
}


// MARK: - クーポンの情報

struct Coupons {
    fileprivate var numberArray: [Int]
    
    init() {
        numberArray = Array(repeating: 0, count: Coupon.count)
    }
    
    init(coupon1: Int, coupon2: Int, coupon3: Int, pizzaCoupon: Int) {
        numberArray = [coupon1, coupon2, coupon3, pizzaCoupon]
    }
    
    // クーポンの枚数を変更する
    fileprivate mutating func alterValue(typeOf coupon: Coupon, value: Int) {
        numberArray[coupon.hashValue] = value
    }
    
    // 指定したクーポンの枚数を返す
    fileprivate func getNumber(_ coupon: Coupon) -> Int {
        return numberArray[coupon.hashValue]
    }
    
    // クーポンの合計枚数を返す
    fileprivate func countAll() -> Int {
        return numberArray.reduce(0) { count, number in
            // (0)はcountの初期値
            // countに要素を加えた結果を新たにcountとする
            count + number
        }
    }
    
    // クーポンの合計値引き額を返す
    fileprivate func totalDiscount() -> Int {
        var total = 0
        for i in 0..<Coupon.count {
            let discount = Coupon.init(rawValue: i)?.getDiscountValue()
            total += discount! * numberArray[i]
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
    
    fileprivate func getDiscountValue() -> Int {
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
    
    fileprivate func getLimitNumber() -> Int {
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
    private var discount: Int = 0
    // 使用したクーポン組み合わせ
    private var selectedCoupons: Coupons
    
    
    init(order: Order, coupons: Coupons) {
        myOrder = order
        myCoupons = coupons
        
        amount = order.getTotalFee()
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
        discount = coupons.totalDiscount()
        pay = amount - discount
        selectedCoupons = coupons
    }
    
    // 最適なクーポンの組み合わせを返す
    func selectCoupons() -> [Int] {
        
        if !isCanUseCoupons() {
            let noCoupon = Array(repeating: 0, count: Coupon.count)
            return noCoupon
        }
        
        // ピザクーポンが使えるなら
        if isCanUsePizzaCoupon() {
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
        
        return selectedCoupons.numberArray
    }
    
    // 使用するクーポンと持っている枚数を渡して値引きするメソッド
    private func useCoupon(typeOf coupon: Coupon, number: Int) {
        
        var couponCount = number
        let value = coupon.getDiscountValue()
        
        if number != 0 {
            // クーポンがなくなるか、支払額が値引額を下回るか、制限枚数使用するまでクーポンを使う
            while (couponCount != 0) && (pay >= value) && ((number - couponCount) != coupon.getLimitNumber()) {
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
    private func isCanUseCoupons() -> Bool {
        // 1000円以下はクーポン対象外
        if amount <= 1000 {
            return false
        } else {
            return true
        }
    }
    
    // ピザクーポンが使えるかどうかを返す
    private func isCanUsePizzaCoupon() -> Bool {
        for menu in myOrder.orderArray {
            if menu.type == Food.pizza {
                return true
            }
        }
        return false
    }
    
    // 使用するクーポンの合計枚数を得る
    private func countCoupons() -> Int {
        return selectedCoupons.numberArray.reduce(0) { count, number in
            // (0)はcountの初期値
            // countに要素を加えた結果を新たにcountとする
            count + number
        }
    }
    
    // 基本クーポンのみを使用
    private func useOnlyNormalCoupon() {
        cancelSelect()
        useCoupon(typeOf: .coupon1, number: myCoupons.getNumber(.coupon1))
        useCoupon(typeOf: .coupon2, number: myCoupons.getNumber(.coupon2))
        useCoupon(typeOf: .coupon3, number: myCoupons.getNumber(.coupon3))
//        self.selectedCoupons.alterValue(typeOf: .pizzaCoupon, value: 0)
    }
    
    // 全てのクーポンを使用
    private func useAllCoupon() {
        cancelSelect()
        // 優先的にピザクーポンを使う
        useCoupon(typeOf: .pizzaCoupon, number: myCoupons.getNumber(.pizzaCoupon))
        useCoupon(typeOf: .coupon1, number: myCoupons.getNumber(.coupon1))
        useCoupon(typeOf: .coupon2, number: myCoupons.getNumber(.coupon2))
        useCoupon(typeOf: .coupon3, number: myCoupons.getNumber(.coupon3))
    }
    
    // 2つのクーポンの組み合わせのうち(値引額->大)かつ(枚数->少)の方を返す
    private func compareCoupons(coupons1 former: Coupons, coupons2 later: Coupons) -> Coupons {
        
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

/*
// フル機能
let myOrder = Order()
myOrder.pizzaOrder(name: .genovese, size: .large, number: 1)
myOrder.sideMenuOrder(name: .frenchFries, number: 1)
//myOrder.SideMenuOrder(name: .GreenSalad, number: 1)
myOrder.sideMenuOrder(name: .caesarSalad, number: 1)
myOrder.pizzaOrder(name: .margherita, size: .middle, number: 1)

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
*/


// アクセスレベルを意識して、最低限使う機能のみでテスト

let myOrder = Order()
myOrder.pizzaOrder(name: .genovese, size: .large, number: 1)
myOrder.sideMenuOrder(name: .frenchFries, number: 1)
myOrder.sideMenuOrder(name: .caesarSalad, number: 1)
myOrder.pizzaOrder(name: .margherita, size: .middle, number: 1)

let myCoupons = Coupons(coupon1: 3, coupon2: 3, coupon3: 4, pizzaCoupon: 2)

let mySelect = SelectOptimumCombination(order: myOrder, coupons: myCoupons)
mySelect.selectCoupons()


















