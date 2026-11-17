package ie.atu.devops.taskmanager.service;

import ie.atu.devops.taskmanager.dto.CreateTaskRequest;
import ie.atu.devops.taskmanager.dto.TaskResponse;
import ie.atu.devops.taskmanager.exception.TaskNotFoundException;
import ie.atu.devops.taskmanager.model.Task;
import ie.atu.devops.taskmanager.repository.TaskRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class TaskService {
    private final TaskRepository repository;

    public TaskService(TaskRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public List<TaskResponse> findAll() {
        return repository.findAll(Sort.by("id")).stream()
                .map(TaskResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public TaskResponse findById(Long id) {
        return TaskResponse.from(findTask(id));
    }

    public TaskResponse create(CreateTaskRequest request) {
        return TaskResponse.from(repository.save(new Task(request.title().trim())));
    }

    public TaskResponse updateStatus(Long id, boolean completed) {
        Task task = findTask(id);
        task.setCompleted(completed);
        return TaskResponse.from(task);
    }

    public void delete(Long id) {
        Task task = findTask(id);
        repository.delete(task);
    }

    private Task findTask(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new TaskNotFoundException(id));
    }
}
