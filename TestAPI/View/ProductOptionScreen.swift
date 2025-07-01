//
//  ProductOptionScreen.swift
//  TestAPI
//
//  Created by Nghia on 20/6/25.
//

import SwiftUI

struct ProductOptionScreen: View {
    
    @State var collections: [ProductCollection] = []
    
    @State private var selectedOptions: [ProductFeature.ID: ProductOption] = [:]
    @State private var selectedModifiers: [Int: [ProductModifierOption]] = [:]
    
    @State var ids : [Int] = [201]
    @State var idsString : String = ""
    @State var productIds : Int = 0
    
    @State private var selectedQuantity : Int = 1
    let maxQuantity : Int = 10
    
    @FocusState private var isFocused : Bool
    
    func findMatchingVariation(for product: Product) -> ProductVariation? {
        let selectedIDs = Set(selectedOptions.values.map { $0.id })
        return product.variations?.first(where: { variation in
            Set(variation.options.map { $0.id }) == selectedIDs
        })
    }
    
    func getDefaultOptions(from product: Product) -> [Int: ProductOption] {
        var defaults: [Int: ProductOption] = [:]
        for feature in product.features ?? [] {
            if let defaultOption = feature.options?.first(where: { $0.isDefault }) {
                var option = defaultOption
                option.feature = feature
                defaults[feature.id] = option
            }
        }
        return defaults
    }
    
    func totalPrice(product: Product) -> Int {
        
        var total = 0
        
        if let matched = findMatchingVariation(for: product) {
            total = matched.price}
        
        for modifier in product.modifiers ?? [] {
            let selectedOptions = selectedModifiers[modifier.id] ?? []
            for option in selectedOptions {
                total += option.price}}
        
        total = total*selectedQuantity
        
        return total
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack{
                        TextField("Nhập collection ID: \(ids)", text: $idsString)
                            .focused($isFocused)
                            .frame(width: 200, height: 30)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                            .onChange(of: idsString) {
                                  ids = idsString
                                     .split(separator: ",")
                                     .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }}

                        Button(action:{
                            if !ids.isEmpty{
                                Task {
                                    do {
                                        collections = try await loadCollectionsByIDs(ids)
                                        selectedQuantity = 1
                                        productIds = 0
                                    }
                                    catch {
                                        print("Error while loading collection...")
                                    }
                                }
                            }
                            isFocused = false
                        })
                        {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: 140, height: 40)
                                    .foregroundStyle(Color("Brown2"))
                                Text("Tìm Collection")
                                    .foregroundStyle(.white)}
                        }
                    }
                }
                if let collection = collections.first {
                    VStack(alignment: .leading, spacing: 20){
                        Text("Collection name: \(collection.name)")
                            .bold().font(.headline)
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
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .tint(Color.black)
                            .cornerRadius(6)
                            .onChange(of: productIds) {
                                let selectedProduct = collection.products[productIds]
                                selectedOptions = getDefaultOptions(from: selectedProduct)
                                selectedModifiers = [:]
                                selectedQuantity = 1
                            }

                        }
                        Divider()
                    }
                    if let product = collection.products[safe: productIds] {
                        VStack(alignment: .leading, spacing: 20) {
                            AsyncImage(url: URL(string: "\(product.images[0])")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .interpolation(.high)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(2)
                                case .failure:
                                    Image(systemName: "photo")
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            HStack(alignment: .bottom){
                                Text("\(product.name)")
                                    .font(.headline)
                                Text("(product ID: \(product.id))")
                                    .font(.subheadline)
                            }
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
                            // Hiển thị các Option đã chọn.
                            if !selectedOptions.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(Array(selectedOptions.keys), id: \.self) { key in
                                        if let option = selectedOptions[key] {
                                            Text("\(option.feature?.name ?? ""): \(option.name)")
                                        }
                                    }
                                }
                            }
                            // Hiển thị Features/Options tương ứng của sản phẩm.
                            ForEach(product.features ?? []) { feature in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(feature.name)
                                        .font(.headline)
                                        .bold()
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            let usedOptionIDs = Set(product.variations?.flatMap { $0.options.map { $0.id } } ?? [])
                                            let validOptions = feature.options?.filter { usedOptionIDs.contains($0.id) } ?? []
                                            ForEach(validOptions) { option in
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
                            // Grid cho các loại Modifier
                            let columns = [
                                GridItem(.flexible(), spacing: 10),
                                GridItem(.flexible())
                            ]
                            if let modifiers = product.modifiers {
                                ForEach(modifiers, id: \.id) { modifier in
                                    Text(modifier.name)
                                        .font(.headline)
                                    Text("Tuỳ chọn \(modifier.name): \((selectedModifiers[modifier.id] ?? []).map { $0.name }.joined(separator: ", "))")
                                        .frame(height: 50)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    LazyVGrid(columns: columns, spacing: 10) {
                                        ForEach(modifier.options, id: \.id) { option in
                                            CheckBox(action:{
                                                let key = modifier.id
                                                var arr = selectedModifiers[key] ?? []
                                                if let index = arr.firstIndex(where: { $0.id == option.id }) {
                                                    arr.remove(at: index)
                                                } else {
                                                    arr.append(option)
                                                }
                                                selectedModifiers[key] = arr
                                            }, isSelected: (selectedModifiers[modifier.id] ?? []).contains(where: { $0.id == option.id }),
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
            .onChange(of: collections.first?.products.first?.id) {
                if let product = collections.first?.products.first {
                    selectedOptions = getDefaultOptions(from: product)
                }
            }
            .onAppear() {
                Task {
                    do {
                        collections = try await loadCollectionsByIDs(ids)
                    }
                    catch {
                        print("error")
                    }
                }
            }
        }
    }
}

#Preview {
    ProductOptionScreen()
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct RadioButton: View {
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
            .foregroundStyle(.black)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

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
            HStack(spacing: 6){
                Button(action: {
                    if quantity > minQuantity {
                        quantity -= 1}
                })
                {
                    Image(systemName: "minus.square.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white, Color("Brown2"))}
                Picker(selection: $quantity, label:
                        Text("\(quantity)")
                        .frame(width: 20)
                        .foregroundColor(.black)
                ) {
                    ForEach(minQuantity...maxQuantity, id: \.self) { value in
                        Text("\(value)").tag(value)}
                }
                .pickerStyle(.menu)
                .frame(width: 60, height: 28)
                .background(Color.white)
                .tint(Color.black)
                .cornerRadius(3)
                Button(action: {
                    if quantity < maxQuantity {
                        quantity += 1}
                })
                {
                    Image(systemName: "plus.square.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white, Color("Brown2"))}
            }.clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
