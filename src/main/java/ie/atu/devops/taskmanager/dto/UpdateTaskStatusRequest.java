package ie.atu.devops.taskmanager.dto;

import jakarta.validation.constraints.NotNull;

public record UpdateTaskStatusRequest(@NotNull Boolean completed) {
}
