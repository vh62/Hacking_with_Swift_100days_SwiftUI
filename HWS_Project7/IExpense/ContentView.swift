//
//  ContentView.swift
//  IExpense
//
//  Created by Vikram Ho on 10/26/20.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable{
    var id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject{
    @Published var items = [ExpenseItem]() {
        didSet{
            let encoder = JSONEncoder()
            
            if let encoded = try?
                encoder.encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items")
        {
            let decoder = JSONDecoder()
            
            if let decoded = try?
                decoder.decode([ExpenseItem].self, from: items){
                self.items = decoded
                return
            }
        }
        self.items = []
    }
}

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    var body: some View {
        NavigationView{
            List{
                ForEach(expenses.items) {
                    item in
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        Spacer()
                        if item.amount >= 100{
                            Text("$\(item.amount)")
                                .fontWeight(.bold)
                                .font(.largeTitle)
                                .foregroundColor(Color.red)
                        }else if item.amount < 10{
                            Text("$\(item.amount)")
                                .foregroundColor(Color.green)
                        }else{
                            Text("$\(item.amount)")
                            .foregroundColor(Color.yellow)
                        }
                        
                    }
                }
                .onDelete(perform: removeItems)
                
            }
            .navigationBarTitle("IExpenses")
            .navigationBarItems(leading:
                HStack{
                    EditButton()
                }
                , trailing:
                HStack{
                    Button(action: {
                        self.showingAddExpense = true
                    }){
                        Image(systemName: "plus")
                        }
                    }
                )
               
            .sheet(isPresented: $showingAddExpense){
                AddView(expenses: self.expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
