//
//  TestView.swift
//  Tich Diem Demo
//
//  Created by Nghia on 20/6/25.
//

import SwiftUI

struct TestView: View {
    
    //Khởi tạo viewModel
    @StateObject private var viewModel = ViewModel()
    
    //selectedOptions : biến lưu các lựa chọn của người dùng cho từng nhóm (feature).
    //Theo dõi người dùng đã chọn gì ở từng nhóm.
    //So sánh với từng dữ liệu product.variations để hiển thị đúng giá tương ứng.
    /* Ex
    | Feature (Group) ID | Feature Name |
    | ------------------ | ------------ |
    | `1`                | Đá           |
    | `2`                | Đường        |
    | `3`                | Size         |
    Người dùng chọn
    | Option ID | Option Name | Feature ID (Nhóm) |
    | --------- | ----------- | ----------------- |
    | `28`      | Đá vừa      | `1`               |
    | `30`      | Ngọt ít     | `2`               |
    | `34`      | Size lớn    | `3`               |
     Thì:
     selectedOptions sẽ là
     selectedOptions = [
        1: ProductOption(id: 28, name: "Đá vừa", feature: Feature(id: 1, name: "Đá")),
        2: ProductOption(id: 30, name: "Ngọt ít", feature: Feature(id: 2, name: "Độ ngọt")),
        3: ProductOption(id: 34, name: "Size lớn", feature: Feature(id: 3, name: "Dung tích"))
     ]*/
    //Dictionary: key là feature.id, value là ProductOption người dùng đã chọn.
    @State private var selectedOptions: [Int: ProductOption] = [:]
    //Tìm variation (có chứa giá tiền) giống với variation mà trong đó chứa ProductOption /Đá, Độ ngọt, Dung tích/ người dùng đã chọn thông qua 3 option.
    //Mỗi sản phẩm (Product) có nhiều variation.
    //Mỗi variation có chứa 3 tuỳ chọn options – tức là những ProductOption cấu thành nên nó (như Đá ít, Ngọt nhiều, Size lớn...).
    //Khi người dùng chọn các option trong mục feature, "dữ liệu ProductOption" đó sẽ được lưu trong selectedOptions: [featureID: ProductOption] tương ứng với feature cha.
    //Hàm bên dưới kiểm tra xem có variation nào khớp với 3 options đó không bằng phương pháp "Set(...map{$0.id}): tập hợp các id".
    func findMatchingVariation(for product: Product) -> ProductVariation? {
        //selectedOptions.values là danh sách các ProductOption người dùng đã chọn
        //.map { $0.id } lấy id của từng ProductOption
        //selectedOptions.values.map { $0.id }
        // -> [28, 30, 34]
        // Set(...) tạo thành một tập hợp các id để dễ so sánh, chuyển vào Set(...), ta được:
        // -> Set([28, 30, 34])
        let selectedIDs = Set(selectedOptions.values.map { $0.id })
        //product.variations? : Lấy danh sách variations từ sản phẩm.
        //Tìm variation đầu tiên (.first(where:...)) trong đó:
        //Tập hợp id của variation.options bằng đúng selectedIDs của người dùng. VD: [27, 30, 33] == [27, 30, 33 ]
        // Điều kiện "khớp":
        //Không dư, không thiếu, không cần đúng thứ tự, chỉ cần đủ phần tử là bằng nhau
        //Nghĩa là người dùng phải chọn đúng bộ options như trong variation nào đó.
        return product.variations?.first(where: { variation in
            Set(variation.options.map { $0.id }) == selectedIDs //Set là tập hợp ko thứ tự dù [27, 30, 33] và [30, 27, 33] có phần tử khác vị trí thì cũng vẫn bằng nhau nên Set([27, 30, 33]) = Set([30, 27, 33])
        })
    }
    
    /*[
       1: ProductOption(id: 28, name: "Đá vừa", feature: Feature(id: 1, name: "Đá")),
       2: ProductOption(id: 30, name: "Ngọt ít", feature: Feature(id: 2, name: "Độ ngọt")),
       3: ProductOption(id: 34, name: "Size lớn", feature: Feature(id: 3, name: "Dung tích"))
    ]*/
    
    /*Hàm setDefaultOptions(from product: Product) có nhiệm vụ thiết lập các lựa chọn mặc định ban đầu (default options) cho từng nhóm lựa chọn (ProductFeature) trong một Product.
    - Product có nhiều features (VD: "Đá", "Ngọt", "Size")
    - Mỗi feature có nhiều options (VD: "Ít đá", "Đá vừa", "Đá nhiều")
    - Trong mỗi options, có thể có 1 cái được đánh dấu là mặc định: isDefault == true*/
    func setDefaultOptions(from product: Product) { //Hàm nhận vào một Product, và sẽ cài các lựa chọn mặc định dựa vào dữ liệu của sản phẩm đó.
        var defaults: [Int: ProductOption] = [:]
        for feature in product.features ?? [] { //Lặp qua tất cả features của sản phẩm. Nếu features bị nil thì dùng mảng rỗng.
            if let defaultOption = feature.options?.first(where: { $0.isDefault }) { //Với mỗi feature, tìm option đầu tiên có isDefault == true
                var option = defaultOption //tạo một biến option (kiểu ProductOption) từ option mặc định tìm được.
                option.feature = feature //Gắn thông tin cha (feature) vào từng option
                defaults[feature.id] = option //Lưu lựa chọn mặc định vào dictionary
            }
        }
        selectedOptions = defaults //gán dictionary defaults này cho selectedOptions để load các giá trị mặc định ban đầu
    }
    // Sử dụng từ điển để phân biệt các Modifier:  Topping và Extra Flavour
    @State private var selectedModifiers: [Int: [String]] = [:]
    // Số lượng và max Số lượng
    @State private var selectedQuantity: Int = 1
    let maxQuantity = 10
    //ID Collection & Sản phẩm
    @State var ids : String = ""
    @State var productIds : Int = 0
    @FocusState private var isFocused : Bool
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                //Chọn Collection và Sản phẩm trong collllection đó
                VStack(alignment: .leading, spacing: 6) {
                    HStack{
                        TextField("Nhập collectionID: \(ids)", text: $ids)
                            .focused($isFocused)
                            .frame(width: 200, height: 30)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                        Button(action:{
                            if !ids.isEmpty{
                                viewModel.ids = ids
                                viewModel.fetch()
                                selectedQuantity = 1
                            }
                            isFocused = false
                            productIds = 0
                        })
                        {
                            ZStack{
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 150, height: 30)
                                    .foregroundStyle(Color("Brown2"))
                                Text("Tìm Collection")
                                    .foregroundStyle(.white)
                            }
                        }
                        .onAppear() {
                            ids = viewModel.ids
                        }
                    }
                    Divider()
                }
                // Chọn sản phẩm có trong Collection.
                if let collection = viewModel.collections.first {
                    VStack {
                        HStack {
                            Text("Chọn sản phẩm: ").bold().font(.headline)
                            Picker(selection: $productIds, label:
                                Text("\(productIds)")
                                    .foregroundColor(.black)
                            ) {
                                ForEach(collection.products.indices, id: \.self) { productIndex in
                                    Text(collection.products[productIndex].name)
                                        .tag(productIndex)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.subheadline)
                            .frame(width: 200, height: 30)
                            .background(Color.white)
                            .tint(Color.black)
                            .onChange(of: productIds) { _ in
                                let selectedProduct = collection.products[productIds]
                                setDefaultOptions(from: selectedProduct)
                                selectedModifiers = [:]
                                selectedQuantity = 1
                            }

                        }
                        Divider()
                    }
                    //Hiển thị sản phẩm và giá
                    //  let product = collection.products.first { //Lấy sản phẩm đầu tiên trong collection đầu tiên.
                    if let product = collection.products[safe: productIds] { //Lấy sản phẩm bất kỳ trong collection đầu tiên để test.
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .bottom){
                                Text("\(product.name)")
                                    .font(.headline)
                                Text("(product ID: \(product.id))")
                                    .font(.subheadline)
                            }
                            /*
                             Gọi hàm findMatchingVariation(for:) để tìm một biến thể (variation) phù hợp với các option người dùng đã chọn.
                             Nếu tìm thấy (không nil), gán vào biến matched.
                             */
                            if let matched = findMatchingVariation(for: product) {
                                HStack{
                                    Text("\(matched.price.formatted())đ")
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(Color("Brown2"))
                                    Text("(variation ID: \(matched.id))")
                                        .font(.subheadline)
                                }
                            } else {
                                Text("Chọn đầy đủ để hiển thị giá")
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            // Hiển thị các lựa chọn đã chọn
                            if !selectedOptions.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Bạn đã chọn:").bold()
                                    //@State private var selectedOptions: [Int: ProductOption]
                                    //Đây là một dictionary (từ điển) lưu trữ các lựa chọn người dùng đã chọn, dạng:
                                    //[featureID: ProductOption]
                                    /*[
                                     1: Option(id: 28, name: "Đá vừa", feature?.name = "Đá"),
                                     2: Option(id: 30, name: "Ngọt ít", feature?.name = "Đường"),
                                     3: Option(id: 34, name: "Size lớn", feature?.name = "Size")
                                     ]*/
                                    // .keys là danh sách feature.id trong selectedOptions.
                                    // Dùng Array(...) để chuyển sang mảng vì ForEach cần mảng để lặp.
                                    // id: \.self là mỗi phần tử trong ForEach là bằng chính giá trị key (Int).
                                    /*selectedOptions:
                                     Ban đầu: [
                                     1: ProductOption(id: 28, name: "Đá vừa", feature: Đá),
                                     2: ProductOption(id: 30, name: "Ngọt ít", feature: Ngọt),
                                     3: ProductOption(id: 34, name: "Size lớn", feature: Size)
                                     ]
                                     .keys: [1, 2, 3] chưa dùng đc với ForEach
                                     Array: [1, 2, 3] giống nhau về nội dung, nhưng kiểu là [Int] (mảng) dùng dc cho ForEach*/
                                    ForEach(Array(selectedOptions.keys), id: \.self) { key in
                                        if let option = selectedOptions[key] {
                                            Text("\(option.feature?.name ?? ""): \(option.name)")
                                        }
                                    }
                                }
                            }
                            // Hiển thị features và options
                            ForEach(product.features ?? []) { feature in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(feature.name)
                                        .font(.headline)
                                        .bold()
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            //Lọc option
                                            //Hiển thị option khả dụng dựa theo id của các option trong từng variation
                                            //Lấy tất cả option.id có trong các variation
                                            //flatmap {...} : Gộp tất cả option.id của mọi variation thành 1 mảng duy nhất
                                            //$0.options.map { $0.id} : Trong từng variation $0, lấy ra mảng options, sau đó map mảng đó thành mảng option.id
                                            //variation 1 = [27, 3, 33], variation 2 = [27, 30 , 34]
                                            //flatmap: [27, 30, 33, 27, 30, 34]
                                            //Set: Bỏ trùng lặp [27, 30, 33, 34]
                                            let usedOptionIDs = Set(product.variations?.flatMap { $0.options.map { $0.id } } ?? [])
                                            //Lọc những option nào có trong usedOptionIDs
                                            //.filter { usedOptionIDs.contains($0.id) } : Duyệt từng option trong feature.options và chỉ giữa lại nếu option.id nằm trong usedOptionIDs. Nói cách khác, chỉ lấy ra những feature option mà trong đó các id (đá ít id : 27, ngọt vừa, size M,...) của nó trùng với id nào đó có trong options của variation (đá ít id : 27)
                                            let validOptions = feature.options?.filter { usedOptionIDs.contains($0.id) } ?? []
                                            //Dùng trong ForEach
                                            ForEach(validOptions) { option in
                                                //Gọi Radio Button component cho từng option
                                                RadioButton(action: {
                                                    var opt = option
                                                    opt.feature = feature
                                                    selectedOptions[feature.id] = opt
                                                }, isSelected: selectedOptions[feature.id]?.id == option.id, optionID: option.id, optionName: option.name, optionDescription: option.description)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                    }
                                }
                            }
                            //Modifiers Grid cho cả Topping và Extra Flavour
                            let columns = [
                                GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible())
                            ]
                            if let modifiers = product.modifiers {
                                ForEach(modifiers, id: \.id) { modifier in
                                    Text(modifier.name)
                                        .font(.headline)
                                    Text("Tuỳ chọn \(modifier.name): \(selectedModifiers[modifier.id]?.joined(separator: ", ") ?? "")")
                                        .frame(height: 50)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(modifier.options ?? [], id: \.id) { option in
                                            //Gọi Check Box Component cho từng modifier Topping hoặc Extra Flavour
                                            CheckBox(action:{
                                                //Lấy id của modifier làm key cho từ điển, ví dụ 1, 2.
                                                let key = modifier.id
                                                //Lấy ra mảng các option đã chọn cho modifier này từ dictionary selectedModifiers. Nếu chưa có, khởi tạo là [].
                                                /*
                                                 Ex: selectedModifiers = [
                                                 1 : ["Trân châu trắng", "Thạch dâu"],
                                                 2 : ["Syrup Caramel"]
                                                 ]
                                                 -> arr = selectedModifiers[1] = ["Trân châu trắng", "Thạch dâu"]
                                                 */
                                                var arr = selectedModifiers[key] ?? []
                                                //Nếu đã chọn option rồi thì xoá khỏi mảng và ngược lại
                                                if arr.contains(option.name) {
                                                    arr.removeAll { $0 == option.name }
                                                } else {
                                                    arr.append(option.name)
                                                }
                                                //Cập nhật lại dictionary selectedModifiers với mảng mới.
                                                selectedModifiers[key] = arr
                                            }, isSelected: (selectedModifiers[modifier.id] ?? []).contains(option.name),
                                                     optionName: option.name, optionDescription: option.description, optionPrice: option.price, optionID: option.id)
                                        }
                                    }
                                }
                                
                            }
                            //Quantity & Total Price
                            VStack(alignment: .leading, spacing: 10){
                                QuantityStepperPicker(quantity: $selectedQuantity, minQuantity: 1, maxQuantity: 10)
                                Spacer()
                                Text("Thành tiền: \(totalPrice(product: product))đ")
                                    .font(.headline)
                                    .foregroundStyle(Color("Brown2"))
                            }
                        }
                    } else{}
                }
                else {
                    Text("Đang tải dữ liệu...")
                }
            }
            .padding()
            .onAppear {
                viewModel.fetch()
            }
            .onChange(of: viewModel.collections.first?.products.first?.id) { _ in
                if let product = viewModel.collections.first?.products.first {
                    setDefaultOptions(from: product)
                }
            }
        }
    }
    func totalPrice(product: Product) -> Int {
        
        var total = 0
        
        // Tìm Price thông qua variation
        if let matched = findMatchingVariation(for: product) {
            total = matched.price
        }
        
        // Nếu chọn thêm modifier
        for modifier in product.modifiers ?? [] {
            let selectedNames = selectedModifiers[modifier.id] ?? []
            
            for option in modifier.options {
                if selectedNames.contains(option.name) {
                    total += option.price
                }
            }
        }
        
        // Chọn số lượng
        total = total*selectedQuantity
        
        // Total Price
        return total
    }
}


#Preview {
    TestView()
}

//Extension Test cho Collection để chọn hiển thị sản phẩm bất kỳ để ngăn crash.
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//Radial Button Component
struct RadioButton: View {
    //Dùng trong ForEach nên không cần giá trị mặc định ban đầu
    let action: () -> Void
    let isSelected : Bool
    let optionID : Int
    let optionName : String
    let optionDescription : String
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button(action:{
                action()
            })
            {
                ZStack {
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                        .overlay(
                            Circle()
                                .stroke(Color("Brown2"), lineWidth: 1)
                        )
                    if isSelected {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color("Brown2"))
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(optionName)
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .bold()
                if !optionDescription.isEmpty {
                    Text(optionDescription)
                }
                Text("ID: \(optionID)")
                    .font(.caption)
            }
            //.frame(width: 90)
            .foregroundStyle(.black)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
//Check Box Component
struct CheckBox: View {
    let action : () -> Void
    let isSelected : Bool
    let optionName : String
    let optionDescription : String
    let optionPrice : Int
    let optionID : Int
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Button(action:{
                action()
            })
            {
                ZStack {
                    Image(systemName: "square")
                        .font(.system(size: 22))
                        .foregroundStyle(Color("Brown2"))
                    if isSelected {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color("Brown2"))
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(optionName)
                    .frame(width: 130, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .bold()
                if !optionDescription.isEmpty {
                    Text(optionDescription).font(.caption)
                }
                Text("+ \(optionPrice)đ")
                Text("ID: \(optionID)").font(.caption)
            }
            .frame(width: 130)
            .foregroundStyle(.black)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct QuantityStepperPicker: View {
    @Binding var quantity: Int
    let minQuantity: Int
    let maxQuantity: Int

    var body: some View {
        HStack(spacing: 20) {
            Text("Số lượng")
                .font(.headline)
                .foregroundStyle(Color("Brown2"))
            HStack(spacing: 0){
                
                // Button -
                Button(action: {
                    if quantity > minQuantity {
                        quantity -= 1
                    }
                }) {
                    Image(systemName: "minus.square.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white, Color("Brown2"))
                }
                
                // Picker
                Picker(selection: $quantity, label:
                        Text("\(quantity)")
                        .frame(width: 20)
                        .foregroundColor(.black)
                ) {
                    ForEach(minQuantity...maxQuantity, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 60, height: 30)
                .background(Color.white)
                .tint(Color.black)
                
                // Button +
                Button(action: {
                    if quantity < maxQuantity {
                        quantity += 1
                    }
                }) {
                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white, Color("Brown2"))
                }
            }.clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
