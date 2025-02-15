//
//  ContentView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var orders: [Order] = []
    @State private var isEditing: Bool = false
    @State private var isCreating: Bool = false
    @State private var selectedOrder: Order? = nil

    private var databaseManager: DRTDatabaseManager
    init(context: NSManagedObjectContext) {
        self.databaseManager = DRTDatabaseManager(context: context)
    }

    var body: some View {
        VStack {
            if orders.isEmpty {
                Text("No orders available.")
                    .padding()
            }

            List(orders, id: \.oid) { order in
                VStack(alignment: .leading) {
                    Text(order.buyer_name ?? "Unknown")
                    Text("OID: \(order.oid ?? 1)")
                    Text("CC: \(order.cc ?? "Unknown")")
                    Text("Phone: \(order.phone ?? "Unknown")")
                }
                .contextMenu {
                    Button(action: {
                        deleteOrder(order: order)
                    }) {
                        Text("Delete Order")
                        Image(systemName: "trash")
                    }

                    Button(action: {
                        selectedOrder = order
                        isEditing = true
                    }) {
                        Text("Edit Order")
                        Image(systemName: "pencil")
                    }
                }
            }

            Button("Add Order") {
                isCreating = true
            }
            .padding()
        }
        .onAppear {
            fetchOrders()
        }
        .sheet(isPresented: $isCreating) {
            CreateOrderView(onCreate: { orderAttributes in
                createOrder(orderAttributes: orderAttributes)
            })
        }
        .sheet(isPresented: $isEditing) {
            if let order = selectedOrder {
                EditOrderView(order: order, onUpdate: { updatedAttributes in
                    updateOrder(orderAttributes: updatedAttributes)
                })
            }
        }
    }

    private func createOrder(orderAttributes: [String: Any]) {
        databaseManager.createOrder(orderAttributes: orderAttributes, context: viewContext) { success in
            if success {
                print("Order created successfully.")
                fetchOrders()
            }
        }
    }

    private func updateOrder(orderAttributes: [String: Any]) {
        databaseManager.updateOrder(orderAttributes: orderAttributes, context: viewContext) { success in
            if success {
                print("Order updated successfully.")
                fetchOrders()
            }
        }
    }

    private func fetchOrders() {
        databaseManager.fetchOrders(context: viewContext) { orders in
            if let fetchedOrders = orders {
                self.orders = fetchedOrders
                print("Fetched \(fetchedOrders.count) orders.")
            }
        }
    }

    private func deleteOrder(order: Order) {
        databaseManager.deleteOrder(order: order, context: viewContext) { success in
            if success {
                fetchOrders()
            }
        }
    }
}
