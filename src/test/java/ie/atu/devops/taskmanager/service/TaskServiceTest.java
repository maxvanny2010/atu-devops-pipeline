package ie.atu.devops.taskmanager.service;

import ie.atu.devops.taskmanager.dto.CreateTaskRequest;
import ie.atu.devops.taskmanager.exception.TaskNotFoundException;
import ie.atu.devops.taskmanager.model.Task;
import ie.atu.devops.taskmanager.repository.TaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TaskServiceTest {
    @Mock
    TaskRepository repository;

    private TaskService service;

    @BeforeEach
    void setUp() {
        service = new TaskService(repository);
    }

    @Test
    void createsTaskWithTrimmedTitle() {
        when(repository.save(any(Task.class))).thenAnswer(invocation -> invocation.getArgument(0));
        var created = service.create(new CreateTaskRequest("  Learn CI/CD  "));
        assertEquals("Learn CI/CD", created.title());
        assertFalse(created.completed());
        verify(repository).save(any(Task.class));
    }

    @Test
    void updatesTaskStatus() {
        Task task = new Task("Add tests");
        when(repository.findById(10L)).thenReturn(Optional.of(task));
        assertTrue(service.updateStatus(10L, true).completed());
        assertTrue(task.isCompleted());
    }

    @Test
    void rejectsMissingTask() {
        when(repository.findById(99L)).thenReturn(Optional.empty());
        assertThrows(TaskNotFoundException.class, () -> service.findById(99L));
    }

    @Test
    void deletesExistingTask() {
        Task task = new Task("Delete me");
        when(repository.findById(5L)).thenReturn(Optional.of(task));
        service.delete(5L);
        verify(repository).delete(task);
    }
}
