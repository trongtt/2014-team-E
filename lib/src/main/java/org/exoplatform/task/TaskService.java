package org.exoplatform.task;

import java.util.List;

import org.exoplatform.task.model.Comment;
import org.exoplatform.task.model.Project;
import org.exoplatform.task.model.Query;
import org.exoplatform.task.model.Task;

public interface TaskService {

    /**
     * Return owner and shared projects
     *
     * @param username
     */
    public List<Project> getProjectsByUser(String username);

    /**
     * create project <br/>
     * throw exception if duplicated, owner doesn't exits, fail validation
     * @param p
     */
    public Project createProject(Project p) throws TaskServiceException;

    public void updateProject(Project p) throws TaskServiceException;

    public Project getProject(String id);

    public void removeProject(String id);

    public Task addTask(Task t) throws TaskServiceException;

    /**
     * Remove the task for the given id if exist.
     * 
     * @param id
     * @return the task with given id, or null if there was no task with given id.
     */
    public Task removeTask(String id);

    public Task updateTask(Task t) throws TaskServiceException;

    public Task getTask(String id);

    public List<Task> getTasksByProject(String projectId, int offset, int limit);
    
    public List<Task> findTasks(Query query, int offset, int limit);
    
    public Comment getCommentById(String id);
    
    public List<Comment> getCommentByTask(String taskId, int offset, int limit);
    
    public Comment addComment(Comment comment);
    
    public Comment removeComment(String commentId);
    
    public Comment updateComment(Comment comment);
}
