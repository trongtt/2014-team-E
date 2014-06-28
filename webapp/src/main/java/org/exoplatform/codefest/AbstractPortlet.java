/*
 * Copyright (C) 2014 eXo Platform SAS.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */
package org.exoplatform.codefest;

import org.exoplatform.commons.utils.ListAccess;
import org.exoplatform.container.ExoContainer;
import org.exoplatform.container.ExoContainerContext;
import org.exoplatform.portal.application.PortalRequestContext;
import org.exoplatform.services.organization.OrganizationService;
import org.exoplatform.services.organization.User;
import org.exoplatform.task.TaskService;
import org.exoplatform.task.model.Project;
import org.exoplatform.task.model.Task;
import org.exoplatform.web.application.ApplicationMessage;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.GenericPortlet;
import javax.portlet.PortletContext;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

/**
 * @author <a href="trongtt@gmail.com">Trong Tran</a>
 * @version $Revision$
 */
public abstract class AbstractPortlet extends GenericPortlet {

    TaskService service;
    OrganizationService orgService;

    @Override
    public void init() throws PortletException {
        super.init();
        ExoContainer container = ExoContainerContext.getCurrentContainer();
        orgService = (OrganizationService)container.getComponentInstanceOfType(OrganizationService.class);
        service = (TaskService)container.getComponentInstanceOfType(TaskService.class);
    }

    public void pushNotification(String message) {
        PortalRequestContext ctx = org.exoplatform.portal.webui.util.Util.getPortalRequestContext();
        ctx.getUIApplication().getUIPopupMessages().addMessage(new ApplicationMessage(message, null));
    }

    @Override
    protected void doView(RenderRequest request, RenderResponse response) throws PortletException, IOException {
        String user = request.getRemoteUser();
        //TODO: process if user is not logged in

        //Load recent project
        List<Project> recentProjects = service.getProjectsByUser(user);
        request.setAttribute("recentProjects", recentProjects);

        String view = request.getParameter("view");
        if (view != null) {
            if (view.equals("issues")) {

                String projectId = request.getParameter("projectId");

                Project project = service.getProject(projectId);
                List<Task> tasks = service.getTasksByProject(projectId, 0, -1);
                request.setAttribute("project", project);
                request.setAttribute("tasks", tasks);

                render("/issues.jsp", request, response);
                return;
            }

            if(view.equals("detail")) {
                String taskId = request.getParameter("taskId");
                Task task = service.getTask(taskId);
                String projectId = task.getProjectId();
                Project project = service.getProject(projectId);

                //. Load all user of this project
                Set<String> membershipts = project.getMemberships();
                Map<String, User> users = new HashMap<String, User>();
                try {
                    User u = orgService.getUserHandler().findUserByName(user);
                    users.put(u.getUserName(), u);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                for(String group : membershipts) {
                    try {
                        ListAccess<User> list = orgService.getUserHandler().findUsersByGroupId(group);
                        int size = list.getSize();
                        for(User u : list.load(0, size)) {
                            users.put(u.getUserName(), u);
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }


                request.setAttribute("project", project);
                request.setAttribute("task", task);
                request.setAttribute("usersInProject", users);

                render("/detail.jsp", request, response);
                return;
            }
        }

        //. Projects view
        List<Project> projects;
        if(user != null) {
            projects = service.getProjectsByUser(user);
        } else {
            projects = new ArrayList<Project>();
        }

        Collections.sort(projects, new Comparator<Project>() {
            @Override
            public int compare(Project o1, Project o2) {
                Date d1 = new Date(o1.getDateCreated());
                Date d2 = new Date(o2.getDateCreated());
                return d1.compareTo(d2);
            }
        });
        request.setAttribute("projects", projects);

        //. Load all group and membership
        Collection groups = null;
        Collection membershipTypes = null;
        try {
            groups = orgService.getGroupHandler().getAllGroups();
            membershipTypes = orgService.getMembershipTypeHandler().findMembershipTypes();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        if(groups == null) {
            groups = Collections.emptyList();
        }
        if(membershipTypes == null) {
            membershipTypes = Collections.emptyList();
        }
        request.setAttribute("userGroups", groups);
        request.setAttribute("membershipTypes", membershipTypes);

        String action = request.getParameter("action");
        if (action != null) {
            request.setAttribute("_project", service.getProject(request.getParameter("objectId")));
        }
        render("/projects.jsp", request, response);
    }

    public void render(String template, RenderRequest request, RenderResponse response) throws PortletException, IOException {
        PortletContext context = getPortletContext();
        context.getRequestDispatcher("/includes/begin.jsp").include(request, response);
        context.getRequestDispatcher(template).include(request, response);
        context.getRequestDispatcher("/includes/end.jsp").include(request, response);
    }

    @Override
    public void processAction(ActionRequest request, ActionResponse response) throws PortletException, IOException {
        String controller = request.getParameter("objectType");

        if("project".equals(controller)) {
            this.processProject(request, response);
        } else if("task".equals(controller)) {
            this.processTask(request, response);
        } else if("comment".equals(controller)) {
            this.processComment(request, response);
        }
    }

    protected abstract void processProject(ActionRequest request, ActionResponse response);

    protected abstract void processTask(ActionRequest request, ActionResponse response);

    protected abstract void processComment(ActionRequest request, ActionResponse response);
}
