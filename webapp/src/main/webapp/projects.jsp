<%@ page import="javax.portlet.PortletURL" %>
<%@ page import="java.util.List" %>
<%@ page import="org.exoplatform.task.model.Project" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Collection" %>
<%@ page import="org.exoplatform.services.organization.Group" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="org.exoplatform.services.organization.MembershipType" %>
<%@include file="includes/header.jsp" %>
<%
  List<Project> projects = null;
  try {
      projects = (List<Project>)renderRequest.getAttribute("projects");
  } catch (Throwable ex) {}

  if(projects == null) {
      projects = Collections.EMPTY_LIST;
  }
  Collection groups = (Collection)renderRequest.getAttribute("userGroups");
  Collection membershipTypes = (Collection)renderRequest.getAttribute("membershipTypes");
  if(groups == null) {
    groups = Collections.emptyList();
  }
  if(membershipTypes == null) {
    groups = Collections.emptyList();
  }
%>
<table class="table table-hover">
  <thead>
    <tr>
      <th>Project Name</th>
      <th>Description</th>
      <th>Owner</th>
      <th>Members</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
  <%if(projects.size() == 0) {%>
    <tr>
      <td colspan="5">There are no project of your account, please create one!</td>
    </tr>
  <%} else {
        for(Project project : projects) {
            PortletURL projectURL = renderResponse.createRenderURL();
            projectURL.setParameter("view", "issues");
            projectURL.setParameter("projectId", project.getId());

            PortletURL deleteAction = renderResponse.createActionURL();
            deleteAction.setParameter("objectType", "project");
            deleteAction.setParameter("action", "delete");
            deleteAction.setParameter("objectId", String.valueOf(project.getId()));

            PortletURL editURL = renderResponse.createRenderURL();
            editURL.setParameter("objectType", "project");
            editURL.setParameter("action", "edit");
            editURL.setParameter("objectId", String.valueOf(project.getId()));
            
        %>
    <tr>
      <td><a href="<%=projectURL.toString()%>"><%=project.getName()%></a></td>
      <td><%= project.getDesc()%></td>
      <td><%=project.getOwner()%></td>
      <td class="memberships">
        <%for(String membership : project.getMemberships()) {
            PortletURL unshareURL = renderResponse.createActionURL();
            unshareURL.setParameter("objectType", "project");
            unshareURL.setParameter("action", "unshare");
            unshareURL.setParameter("projectId", project.getId());
            unshareURL.setParameter("membership", membership);
          %>
            <span class="label label-success"><%=membership%> <a class="close" href="<%=unshareURL.toString()%>">&times;</a></span>
        <%}
        <%--<a class="action" action="add" projectId="<%=project.getId()%>" href="#">
          <i class="icon-plus-sign"></i>
        </a>--%>
      </td>
      <td>
        <a href="<%=editURL.toString()%>"><i class="icon-pencil"></i></a>
        <a href="<%=deleteAction.toString()%>"><i class="icon-trash"></i></a>
      </td>
    </tr>
        <%}
    }%>
  </tbody>
</table>

<%
Project p = (Project)renderRequest.getAttribute("_project");
if (p != null) {
%>
<div>
    <form id="form-edit-project" action="<portlet:actionURL />" method="POST" class="form-horizontal">
        <fieldset>
            <legend>Edit project</legend>
            <div>
                <input type="hidden" name="objectType" value="project"/>
                <input type="hidden" name="action" value="edit"/>
                <input type="hidden" name="projectId" value="<%=p.getId()%>"/>
            </div>
            <div class="control-group">
                <label class="control-label" for="inputName">Project name</label>
                <div class="controls">
                    <input type="text" name="name" id="inputName" placeholder="Name of project" value="<%=p.getName()%>">
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">Description</label>
                <div class="controls">
                    <textarea name="description" rows="3"><%=p.getDesc()%></textarea>
                </div>
            </div>
            <div class="control-group">
              <div class="control-label">
                Memberships:
              </div>
              <div class="controls">
                <div class="list-memberships">
                  <%
                    StringBuilder memberships = new StringBuilder();
                  %>
                  <%for(String membership : p.getMemberships()) {
                      if(memberships.length() > 0) {
                        memberships.append(',');
                      }
                      memberships.append(membership);
                  %>
                  <span class="label label-success"><span><%=membership%></span> <a class="close" href="javascript:void(0);">&times;</a></span>
                  <%}%>
                </div>
                <input type="hidden" name="memberships" value="<%=memberships.toString()%>"/>
                <select class="span3" name="group">
                  <option value="">Select group</option>
                  <%
                    Iterator it = groups.iterator();
                    while(it.hasNext()) {
                      Group g = (Group)it.next();%>
                  <option value="<%=g.getId()%>"><%=g.getId()%></option>
                  <%}
                  %>
                </select>
                <select class="span2" name="membershipType">
                  <option value="">Select membership type</option>
                  <%
                    it = membershipTypes.iterator();
                    while(it.hasNext()) {
                      MembershipType type = (MembershipType)it.next();%>
                  <option value="<%=type.getName()%>"><%=type.getName()%></option>
                  <%}
                  %>
                </select>
                <button class="btn" type="button" name="add-membership">Add</button>
              </div>
            </div>
            <div class="control-group">
                <div class="controls">
                    <button type="submit" class="btn">Update</button>
                </div>
            </div>
        </fieldset>
    </form>
</div>
<%    
} else {
%>
<div>
    <form action="<portlet:actionURL />" method="POST" class="form-horizontal">
        <fieldset>
            <legend>Create new project</legend>
            <div>
                <input type="hidden" name="objectType" value="project"/>
                <input type="hidden" name="action" value="create"/>
            </div>
            <div class="control-group">
                <label class="control-label" for="inputName">Project name</label>
                <div class="controls">
                    <input type="text" name="name" id="inputName" placeholder="Name of project">
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">Description</label>
                <div class="controls">
                    <textarea name="description" rows="3"></textarea>
                </div>
            </div>
            <div class="control-group">
                <div class="controls">
                    <button type="submit" class="btn">Create</button>
                </div>
            </div>
        </fieldset>
    </form>
</div>
<div class="UIPopupWindow uiPopup UIDragObject NormalStyle" id="UIPopupAddMembership" style="width: 500px;display: none; visibility: visible; z-index: 11; top: 88px; left: 328px;">
  <div class="popupHeader clearfix">

    <%--<a class="uiIconClose pull-right" title="Close Window" href="javascript:void(0);"></a>--%>

    <span class="PopupTitle popupTitle">Select Group and Membership</span>
  </div>
  <div class="PopupContent popupContent">
    <form action="<portlet:actionURL />" method="POST" class="form-inline">
      <div class="uiDocActivitySelector" id="UIDocActivitySelector">
        <div>
          <input type="hidden" name="objectType" value="project"/>
          <input type="hidden" name="action" value="share"/>
          <input type="hidden" name="projectId" value=""/>
        </div>
        <div>
          <select class="span3" name="group">
            <option value="">Select group</option>
            <%
              Iterator it = groups.iterator();
              while(it.hasNext()) {
                Group g = (Group)it.next();%>
                <option value="<%=g.getId()%>"><%=g.getId()%></option>
              <%}
            %>
          </select>
          <select class="span2" name="membershipType">
            <option value="">Select membership type</option>
            <%
              it = membershipTypes.iterator();
              while(it.hasNext()) {
                MembershipType type = (MembershipType)it.next();%>
                <option value="<%=type.getName()%>"><%=type.getName()%></option>
              <%}
            %>
          </select>
        </div>
        <div class="uiAction uiActionBorder">
          <button class="btn" type="submit">Add</button>
          <button class="btn" type="reset">Cancel</button>
        </div>
      </div>
    </form>
  </div>
</div>
<%}%>