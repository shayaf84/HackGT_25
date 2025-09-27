//
//  TasksView.swift
//  Heartifacts
//
//  Created by Shaya Farahmand on 9/27/25.
//

import SwiftUI

struct TasksView: View {
    @State private var tasks = [
        TaskItem(title: "Complete daily meditation", isCompleted: false),
        TaskItem(title: "Review museum artifacts", isCompleted: true),
        TaskItem(title: "Update exhibit descriptions", isCompleted: false),
        TaskItem(title: "Plan next acquisition", isCompleted: false)
    ]
    
    var body: some View {
        VStack {
            Text("Tasks")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    TaskRowView(task: $tasks[index])
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .background(
            Image("task")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct TaskRowView: View {
    @Binding var task: TaskItem
    
    var body: some View {
        HStack {
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            Text(task.title)
                .foregroundColor(.white)
                .strikethrough(task.isCompleted)
                .opacity(task.isCompleted ? 0.6 : 1.0)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}
