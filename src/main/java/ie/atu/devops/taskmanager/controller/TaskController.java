package ie.atu.devops.taskmanager.controller;

import ie.atu.devops.taskmanager.dto.CreateTaskRequest;
import ie.atu.devops.taskmanager.dto.TaskResponse;
import ie.atu.devops.taskmanager.dto.UpdateTaskStatusRequest;
import ie.atu.devops.taskmanager.service.TaskService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {
    private final TaskService service;

    public TaskController(TaskService service) {
        this.service = service;
    }

    @GetMapping
    public List<TaskResponse> list() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public TaskResponse get(@PathVariable Long id) {
        return service.findById(id);
    }

    @PostMapping
    public ResponseEntity<TaskResponse> create(@Valid @RequestBody CreateTaskRequest request) {
        TaskResponse created = service.create(request);
        return ResponseEntity.created(URI.create("/api/tasks/" + created.id()))
                .body(created);
    }

    @PatchMapping("/{id}")
    public TaskResponse updateStatus(@PathVariable Long id,
                                     @Valid @RequestBody UpdateTaskStatusRequest request) {
        return service.updateStatus(id, request.completed());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
