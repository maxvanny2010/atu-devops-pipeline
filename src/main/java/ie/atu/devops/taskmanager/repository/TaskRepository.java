package ie.atu.devops.taskmanager.repository;

import ie.atu.devops.taskmanager.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> {
}
