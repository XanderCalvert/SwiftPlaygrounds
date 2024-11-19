import SwiftUI
// Imports the SwiftUI framework, which provides the tools for building user interfaces.

struct Task: Identifiable, Codable {
    // Defines a data structure to represent a task in the to-do list.
    var id: UUID = UUID() // A unique identifier for each task.
    var name: String // The name or title of the task.
    var isDone: Bool // Tracks whether the task is completed or not.
}

struct ContentView: View {
    // Defines the main view of the app.

    @State private var tasks: [Task] = []
    // Stores the list of tasks. `@State` allows SwiftUI to track changes and update the UI.
    
    @State private var newTask: String = ""
    // Tracks the text entered in the new task input field.
    
    @State private var editingTaskID: UUID? = nil
    // Keeps track of the ID of the task currently being edited (if any).
    
    @State private var isDarkMode: Bool = false
    // Tracks whether dark mode is enabled.

    var body: some View {
        // The body defines the user interface.
        NavigationView {
            // Embeds the UI in a navigation view, which provides navigation-related features.
            VStack {
                // Vertically stacks its child views.
                
                // Add a toggle for dark mode
                HStack {
                    Spacer()
                    Toggle(isOn: $isDarkMode) {
                        Text("Dark Mode")
                            .font(.caption)
                    }
                    .padding()
                }
                
                // Input field and add button
                HStack {
                    // Horizontally stacks the text field and the button.
                    
                    TextField("Enter a new task", text: $newTask)
                        // A text input field for entering a new task. The `text` parameter binds to `newTask`.
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        // Applies a rounded border style to the text field.
                        .padding()
                        // Adds padding around the text field.

                    Button(action: addTask) {
                        // A button that calls `addTask` when tapped.
                        Text("Add")
                            // The text displayed on the button.
                            .padding()
                            // Adds padding inside the button.
                            .background(Color.blue)
                            // Sets the button's background colour to blue.
                            .foregroundColor(.white)
                            // Sets the text colour to white.
                            .cornerRadius(8)
                            // Rounds the button's corners.
                    }
                }

                // Task list
                List {
                    // Displays a scrollable list of tasks.
                    ForEach($tasks) { $task in
                        // Iterates over the tasks, creating a row for each task. `$task` provides a binding to the task.
                        
                        HStack {
                            // Horizontally stacks the task's toggle and text field.
                            if editingTaskID == task.id {
                                // Checks if the current task is being edited.
                                TextField("Edit Task", text: $task.name, onCommit: {
                                    // A text field for editing the task name. Updates the name when editing is finished.
                                    editingTaskID = nil // Exit editing mode on return.
                                    saveTasks() // Save changes to persistent storage.
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                // Applies a rounded border style to the text field.
                            } else {
                                // If the task is not being edited:
                                Toggle(isOn: $task.isDone) {
                                    // A toggle (checkbox) to mark the task as done or not done.
                                    Text(task.name)
                                        // Displays the task name.
                                        .strikethrough(task.isDone, color: .gray)
                                        // Adds a strikethrough if the task is marked as done.
                                        .foregroundColor(task.isDone ? .gray : .primary)
                                        // Sets the text colour to gray if done, otherwise uses the default colour.
                                }
                                .onTapGesture {
                                    // Allows tapping the row to enter editing mode.
                                    editingTaskID = task.id // Set the editing task ID to the current task.
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)
                    // Adds swipe-to-delete functionality for the tasks.
                }
                .listStyle(PlainListStyle())
                // Sets the list style to a plain style.
            }
            .navigationTitle("To-Do List")
            // Sets the navigation bar title.
            .onAppear {
                // Executes code when the view appears.
                loadTasks()
                // Loads tasks from persistent storage.
            }
            // Dynamically set the colour scheme based on the toggle.
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }

    private func addTask() {
        // Adds a new task to the list.
        if !newTask.isEmpty {
            // Only add the task if the input field is not empty.
            tasks.append(Task(name: newTask, isDone: false))
            // Create a new task with the entered name and a default `isDone` value of `false`.
            newTask = "" // Clear the input field.
            saveTasks() // Save tasks to persistent storage.
        }
    }

    private func deleteTask(at offsets: IndexSet) {
        // Deletes tasks from the list.
        tasks.remove(atOffsets: offsets)
        // Removes tasks at the specified offsets.
        saveTasks() // Save tasks to persistent storage.
    }

    private func saveTasks() {
        // Saves the tasks array to persistent storage using `UserDefaults`.
        if let encoded = try? JSONEncoder().encode(tasks) {
            // Encodes the tasks array into JSON.
            UserDefaults.standard.set(encoded, forKey: "tasks")
            // Stores the JSON data in UserDefaults with the key "tasks".
        }
    }

    private func loadTasks() {
        // Loads the tasks array from persistent storage.
        if let savedTasks = UserDefaults.standard.data(forKey: "tasks"),
           // Retrieves the data for the key "tasks".
           let decoded = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            // Decodes the JSON data back into an array of `Task` objects.
            tasks = decoded
            // Updates the tasks array with the decoded data.
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    // Provides a preview of the ContentView in Xcode.
    static var previews: some View {
        ContentView()
    }
}
