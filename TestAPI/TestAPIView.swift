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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Hiển thị các lựa chọn đã chọn
                if !selectedOptions.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
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

                // Hiển thị sản phẩm và giá
                if let collection = viewModel.collections.first,
                //  let product = collection.products.first { //Lấy sản phẩm đầu tiên trong collection đầu tiên.
                    let product = collection.products[safe: 2] { //Lấy sản phẩm thứ 3 trong collection đầu tiên để test.
                    VStack(alignment: .leading, spacing: 20) {
                        Text("\(product.name) (ID: \(product.id))")
                            .font(.headline)
                        
                        /*
                         Gọi hàm findMatchingVariation(for:) để tìm một biến thể (variation) phù hợp với các option người dùng đã chọn.
                         Nếu tìm thấy (không nil), gán vào biến matched.
                         */
                        
                        if let matched = findMatchingVariation(for: product) {
                            Text("\(matched.price.formatted()) đ")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color("Brown2"))
                            Text("\(matched.id)")
                        } else {
                            Text("Chọn đầy đủ để hiển thị giá")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        
                        // Hiển thị features và options
                        ForEach(product.features ?? []) { feature in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(feature.name)
                                    .font(.headline)
                                    .bold()
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        
                                        /*ForEach(feature.options ?? []) { option in //option có dạng ProductOption
                                            
                                            Button(action: {
                                                var opt = option //Tạo một bản sao của option
                                                opt.feature = feature //Gắn lại feature vào option đó → để sau này có thể hiển thị lại "Đá: Đá vừa".
                                                selectedOptions[feature.id] = opt //Lưu option vừa chọn vào selectedOptions với feature.id làm key.
                                                /*Nếu feature.id = 1 là "Đá", và người dùng chọn "Đá vừa", thì:
                                                 selectedOptions = [
                                                     1: ProductOption(id: 28, name: "Đá vừa", feature: "Đá")
                                                 ]*/
                                            }) {
                                                HStack(alignment: .top, spacing: 5) {
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundStyle(.white)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(Color("Brown2"), lineWidth: 1)
                                                            )
                                                        if selectedOptions[feature.id]?.id == option.id {
                                                            Circle()
                                                                .frame(width: 10, height: 10)
                                                                .foregroundStyle(Color("Brown2"))
                                                        }
                                                    }

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(option.name).bold()
                                                        Text("\(option.id)")
                                                        if !option.description.isEmpty {
                                                            Text(option.description).font(.caption)
                                                        }
                                                    }
                                                    .foregroundStyle(.black)
                                                }
                                                .padding(10)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                                            }
                                        }*/ //Chưa lọc option
                                        
                                        //Lọc Option dựa theo variation
                                        //Lấy tất cả option.id có trong các variation
                                        let usedOptionIDs = Set(product.variations?.flatMap { $0.options.map { $0.id } } ?? [])
                                        //Lọc những option nào có trong usedOptionIDs
                                        let validOptions = feature.options?.filter { usedOptionIDs.contains($0.id) } ?? []
                                        //Dùng trong ForEach
                                        ForEach(validOptions) { option in
                                            Button(action: {
                                                var opt = option
                                                opt.feature = feature
                                                selectedOptions[feature.id] = opt
                                            }) {
                                                HStack(alignment: .top, spacing: 5) {
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundStyle(.white)
                                                            .overlay(
                                                                Circle()
                                                                    .stroke(Color("Brown2"), lineWidth: 1)
                                                            )
                                                        if selectedOptions[feature.id]?.id == option.id {
                                                            Circle()
                                                                .frame(width: 10, height: 10)
                                                                .foregroundStyle(Color("Brown2"))
                                                        }
                                                    }

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(option.name).bold()
                                                        Text("\(option.id)")
                                                        if !option.description.isEmpty {
                                                            Text(option.description).font(.caption)
                                                        }
                                                    }
                                                    .foregroundStyle(.black)
                                                }
                                                .padding(10)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                }
                            }
                        }
                    }
                } else {
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
}


#Preview {
    TestView()
}

//Extension Test cho Collection để chọn hiển thị sản phẩm bất kỳ ngăn crash.
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
