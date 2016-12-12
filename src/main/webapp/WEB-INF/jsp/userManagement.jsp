<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">
    
    <title>用户管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<script type="text/javascript" src="js/jquery-easyui-1.4.1/jquery.min.js"></script>
	<link rel="stylesheet" type="text/css" href="js/jquery-easyui-1.4.1/themes/default/easyui.css" />
	<link rel="stylesheet" type="text/css" href="js/jquery-easyui-1.4.1/themes/icon.css" />
	<script type="text/javascript" src="js/jquery-easyui-1.4.1/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="js/jquery-easyui-1.4.1/locale/easyui-lang-zh_CN.js"></script>
	
	<link rel="stylesheet" type="text/css" href="css/common2.css" />
	<script type="text/javascript" src="js/common.js"></script>
	<script type="text/javascript">
		$(function(){
			
			//添加修改标志
			var flag = '';
			//搜索框展开标志
			var searchStatus = 0;
			/**
			 * 表格初始化
			 */
			$('#totalGrid').datagrid({
				
				idField:'userid',
				//ajax异步后台请求
				url: 'userAction_getUserGrid',
				fit: true,
				//自动列间距
				fitColumns: false,
				border: false,
				//分页查询
				pagination: true,
				//加载等待提示
				loadMsg:'数据正在加载中，请耐心等待…',
				//列内容
				columns:[[
				    {
				    	field:'checkbox',
				    	width:50,
				    	checkbox:true
				    },{
				    	title:'用户ID',
						field:'userid',
						width:100,
						hidden: false
				    },{
						title:'用户名',
						field:'loginname',
						width:100,
						sortable: true
					},{
						title:'密码',
						field:'password',
						width:100,
						formatter: function(value,row,index){
							return '******';
						}
					},{
						title:'用户姓名',
						field:'username',
						width:100,
					},{
						title:'用户年龄',
						field:'age',
						width:100,
					},{
						title:'性别',
						field:'sex',
						width:100,
						formatter: function(value,row,index){
							if (value == 1){
								return '男';
							}
							if (value == 0){
								return '女';
							}
						}
					}
				]],
				
				
				//增加工具栏，添加增删改查按钮
				toolbar:[
					{
						text:'添加用户',
						iconCls:'icon-add',
						handler:function(){
							
							//标志为添加
							flag = 'add';
							//动态设定对话框标题
							$('#addDialog').panel({
								title: '添加用户信息'
							});
							$('#addDialog').dialog('open');
							
						}
					},'-',{
						text:'删除用户',
						iconCls:'icon-remove',
						handler:function(){
							
							var arr = $('#totalGrid').datagrid('getSelections');
							if(arr.length < 1) {
								$.messager.show({
									title: '提示信息！',
									msg: '至少选择一行记录进行修改！'
								});
							} else {
								
								$.messager.confirm('提示信息' , '删除后商品信息无法恢复，是否确认删除？' , function(result){
									if(result) {
										
										var ids = '';
										for(var i=0; i<arr.length; i++) {
											ids += arr[i].userid + ',';
										}
										ids = ids.substring(0, ids.length-1);
										$.post('user_delete', {ids:ids}, function(result){
											if(result.success){
												//1.刷新数据表格
												$('#totalGrid').datagrid('reload');
												//2.给出提示信息
												$.messager.show ({
													title: 'ok!',
													msg: result.message
												});
												//3.清楚数据表格勾选
												$('#totalGrid').datagrid('clearSelections');
												
											} else {
												$.messager.show ({
													title: 'fail!',
													msg: result.message
												});
											}
										},'json');
										
									} else {
										return;
									}
								});
								
							}
							
						}						
					},'-',{
						text:'修改用户',
						iconCls:'icon-edit',
						handler:function(){
							
							//标志位修改
							flag = 'edit';
							//动态设定对话框标题
							$('#addDialog').panel({
								title: '修改用户信息'
							});
							var arr = $('#totalGrid').datagrid('getSelections');
							if(arr.length != 1) {
								$.messager.show({
									title: '提示信息！',
									msg: '只能选择一行记录进行修改！'
								});
							} else {
								$('#addDialog').dialog('open');
								$('#addForm').form('reset');
								$('#addForm').form('load',{
									userid: arr[0].userid,
									loginname: arr[0].loginname,
									password1: arr[0].password1,
									password2: arr[0].password2,
									username: arr[0].username,
									age:arr[0].age,
									sex:arr[0].sex,
								});
							}
							
						}						
					}
				]
				
			});
			
			/**
			 * 表单提交按钮
			 */
			$('#saveButton').click(function(){
				if($('#addForm').form('validate')){
					$.ajax({
						type: 'post',
						url: flag=='add'? 'user_add' : 'user_update',
						cache: false,
						data: $('#addForm').serialize(),
						dataType: 'json',
						success: function(result) {
							$('#addDialog').dialog('close');
							if(result.success){
								$.messager.show ({
									title: "ok!",
									msg: result.message
								});
								$('#addForm').form('reset');
								$('#totalGrid').datagrid('reload');
							} else {
								$.messager.show ({
									title: "fail!",
									msg: result.message
								});
							}
						},
					});
				} else {
					$.messager.show({
						title: '提示信息' ,
						msg: '数据有误，不能保存！'
					});
				}
			});
			
			/**
			 * 表单取消按钮
			 */
			$('#cancelButton').click(function(){
				$('#addDialog').dialog('close');
			});
			
			/**
			 * 搜索按钮
			 */
			$('#searchButton').click(function() {
				$('#totalGrid').datagrid('load', serializeForm($('#commoditySearch')));
			});
			
			/**
			 * 清空按钮
			 */
			$('#clearButton').click(function() {
				$('#commoditySearch').form('reset');
			});
			
			/**
			 * 性别下拉菜单
			 */
			$('#sex').combobox({
				editable:false,
			    valueField:'value',
			    textField:'text',
			    width:100,
			    panelHeight:60,
			    data:[{
			    	text:'男',
			    	value:1
			    },{
			    	text:'女',
			    	value:'0'
			    }]
			});
			
		});
		
		//js方法：序列化表单 			
		function serializeForm(form) {
			var obj = {};
			$.each(form.serializeArray(), function(index) {
				if (obj[this['name']]) {
					obj[this['name']] = obj[this['name']] + ',' + this['value'];
				} else {
					obj[this['name']] = this['value'];
				}
			});
			return obj;
		}
		
	
	</script>
	
		
  </head>
  
  <body>
  	<div id="lay" class="easyui-layout" fit=true >
		<div region="center" title="商品信息管理">
			<table id="totalGrid"></table>
		</div>
	</div>
	<div id="addDialog" title="添加用户信息" modal=true class="easyui-dialog"
		closed=true style="width:530px;padding:30px;">
		<form id="addForm" method="post">
		<input type="hidden" id="userid" name="userid" class="textbox" />
			<div style="margin:10px;">
				<table cellspacing="8px">
					<tr height="30px">
						<td>用户名：</td>
						<td><input name="loginname" class="easyui-textbox" required=true missingMessage="请填写用户名" validType="loginname" delay=2 /></td>
						<td>性别：</td>
						<td><input id="sex" name="sex" /></td>
					</tr>
					<tr height="30px">
						<td>输入密码：</td>
						<td><input id="password1" name="password1" class="easyui-textbox" type="password" required=true missingMessage="请填写密码" /></td>
						<td>确认密码：</td>
						<td><input id="password2" name="password2" class="easyui-textbox" type="password" validType="same['password1']" required=true missingMessage="请确认密码" /></td>
					</tr>
					<tr height="30px">
						<td>用户姓名：</td>
						<td><input name="username" class="easyui-textbox" /></td>
						<td>年龄：</td>
						<td><input name="age" class="easyui-numberbox" min=0 max=150 /></td>
					</tr>
				</table>
			</div>
			<div class="clear"></div>
			<div style="margin:10px;text-align:center">
				<a id="saveButton" class="easyui-linkbutton" iconCls="icon-save" style="margin-right:10px">保存</a>
				<a id="cancelButton" class="easyui-linkbutton" iconCls="icon-cancel" style="margin-left:10px">取消</a>
			</div>
			
		</form>
	</div>
</body>
</html>
