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
    
    <title>商品信息管理</title>
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
	<script type="text/javascript" src="js/commons.js"></script>
	<script type="text/javascript">
		$(function(){
			/**
			 * 表格初始化
			 */
			$('#commodityTable').datagrid({
				
				idField:'id',
				//ajax异步后台请求
				url: 'commodityAction_getCommodityList',
				fit: true,
				//自动列间距
				fitColumns: true,
				border: false,
				//加载等待提示
				loadMsg:'数据正在加载中，请耐心等待…',
				//列内容
				columns:[[
				    {
				    	field:'checkbox',
				    	width:50,
				    	checkbox:true
				    },{
						title:'商品编号',
						field:'commodityId',
						width:100
					},{
						title:'商品名称',
						field:'commodityName',
						width:100
					},{
						title:'商品条码',
						field:'commodityBar',
						width:100
					},{
						title:'规格型号',
						field:'commodityType',
						width:100
					},{
						title:'商品分类',
						field:'commodityCategory.commodityCategoryName',
						width:100,
						formatter: function (val, row) {
							return row.commodityCategory.commodityCategoryName;
						}
					},{
						title:'计量单位',
						field:'commodityUnit.unitName',
						width:100,
						formatter: function(value,row){
							return row.commodityUnit.unitName;
						}

					},{
						title:'备注',
						field:'remark',
						width:100
					}
				]],
				//分页查询
				pagination: true,
				//增加工具栏，添加增删改查按钮
				toolbar:[
					{
						text:'添加商品信息',
						iconCls:'icon-add',
						handler:function(){
							$('#addDialog').dialog('open');
						}
					},{
						text:'删除商品信息',
						iconCls:'icon-remove',
						handler:function(){}						
					},{
						text:'修改商品信息',
						iconCls:'icon-edit',
						handler:function(){
							var arr = $('#commodityTable').datagrid('getSelections');
							if(arr.length > 1) {
								$.messager.show({
									title: '提示信息！',
									msg: '只能选择一行记录进行修改！'
								});
							} else if(arr.length == 0) {
								$.messager.show({
									title: '提示信息！',
									msg: '请选择一行记录进行修改！'
								});
							} else {
								$('#addDialog').dialog('open');
								$('#addForm').form('reset');
								$('#addForm').form('load',{
									commodityId: arr[0].commodityId,
									commodityName: arr[0].commodityName,
									commodityBar: arr[0].commodityBar,
									commodityType: arr[0].commodityType,
									commodityCategoryId: arr[0].commodityCategory.commodityCategoryName,
									unitName: arr[0].commodityUnit.unitName,
									remark: arr[0].remark
								});
							}
						}						
					},{
						text:'查询商品信息',
						iconCls:'icon-search',
						handler:function(){}
					}
				]
				
			});
			
			/**
			 * 商品编号输入框初始化
			 */
			$('#commodityId').validatebox({
				required : true ,
				validType : 'midLength[2,5]' , 
				invalidMessage : '商品编号必须在2到5个长度之间' ,
				missingMessage : '请填写商品编号'
			});
			
			/**
			 * 表单提交按钮
			 */
			$('#saveButton').click(function(){
				if($('#addForm').form('validate')){
					$.ajax({
						type: 'post',
						url: 'commodityAction_addCommodity',
						cache: false,
						data: $('#addForm').serialize(),
						dataType: 'json',
						success: function(result) {
							$('#addDialog').dialog('close');
							$.messager.show({
								title: result.status,
								msg: result.message
							});
						},
						error: function(result) {
							$.messager.show({
								title: result.status,
								msg: result.message
							});
						}
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
		});
		
	
	</script>
	
		
  </head>
  
  <body>
  	<div id="lay" class="easyui-layout" fit=true >
		<div region="north" title="商品信息查询" style="height:100px;" >
		
		</div>
		<div region="center" title="商品信息管理">
			<table id="commodityTable"></table>
		</div>
	</div>
	<div id="addDialog" title="添加商品信息" modal=true class="easyui-dialog"
		closed=true style="width:550px;padding:30px;">
		<form id="addForm" method="post">
			<div>
				<table style="width:100%;">
					<tr>
						<td>商品编号：</td>
						<td><input type="text" id="commodityId" name="commodityId"
							class="textbox" /></td>
						<td>商品名称：</td>
						<td><input name="commodityName"
							class="easyui-validatebox textbox" required=true
							missingMessage="请填写商品名称" /></td>
					</tr>
					<tr>
						<td>商品条码：</td>
						<td><input name="commodityBar" class="textbox" /></td>
						<td>规格型号：</td>
						<td><input name="commodityType" class="textbox" /></td>
					</tr>
					<tr>
						<td>商品类别：</td>
						<td><input name="commodityCategory.commodityCategoryId" class="textbox" /></td>
						<td>计量单位：</td>
						<td><input id="commodityUnit" name="commodityUnit.unitName" class="textbox" /></td>
					</tr>
				</table>
			</div>
			<div style="margin-bottom:15px;">
				<div style="margin-bottom:5px;">备注：</div>
				<input name="remark" class="easyui-textbox" multiline="true"
					style="width:100%;height:100px;" />
			</div>
			<div style="padding:5px 0;text-align:right;">
				<a id="saveButton" class="easyui-linkbutton" iconCls="icon-save">保存</a>
				<a id="cancelButton" class="easyui-linkbutton" iconCls="icon-cancel">取消</a>
			</div>
		</form>
	</div>


</body>
</html>
