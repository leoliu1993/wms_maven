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
    
    <title>库存查询</title>
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
	<script type="text/javascript" src="js/json2.js"></script>
	
	<link rel="stylesheet" type="text/css" href="css/common2.css" />
	<script type="text/javascript" src="js/commons.js"></script>
	<script type="text/javascript">
		$(function(){
			
			//添加修改标志
			var flag = '';
			//搜索框展开标志
			var searchStatus = 0;
			
			/**
			 * 表格初始化
			 */
			$('#supplierTable').datagrid({
				
				idField:'orderId',
				//ajax异步后台请求
				url: 'stockManagement_getStockWarningTotalGrid',
				fit: true,
				//自动列间距
				fitColumns: false,
				border: false,
				//分页查询
				pagination: true,
				//加载等待提示
				loadMsg:'数据正在加载中，请耐心等待…',
				singleSelect:true,
				rownumbers:true,
				//列内容
				columns:[[
				    {
				    	title:'库存总单ID',
						field:'orderId',
						width:100,
						hidden: true
				    },{
						title:'商品ID',
						field:'commodityId',
						width:100,
						hidden: true
					},{
						title:'商品名称',
						field:'commodityName',
						width:100,
						sortable: false
					},{
						title:'订购量',
						field:'purchase',
						width:100
					},{
						title:'入库量',
						field:'inStock',
						width:100,
					},{
						title:'出库量',
						field:'outStock',
						width:100,
					},{
						title:'可见销售量',
						field:'visibleStock',
						width:100,
					},{
						title:'库存量',
						field:'stockAmount',
						width:100,
					}
				]],
				
				//添加点击事件
				onClickRow:function(rowIndex,rowData){
					var ids = rowData.commodityId;
			        $('#detailGrid').datagrid('options').url = 'commodityAction_getDatagrid';
			        $('#detailGrid').datagrid('load', {commodityId:ids}); 
				}
				
				
				
				
			});
			
			/**
			 * 详单表格初始化
			 */
			$('#detailGrid').datagrid({
				
				idField:'commodityId',
				//ajax异步后台请求
				url: '',
				fit: true,
				//自动列间距
				fitColumns: false,
				border: false,
				//分页查询
				pagination: false,
				//加载等待提示
				loadMsg:'数据正在加载中，请耐心等待…',
				//列内容
				columns:[[
				    {
				    	title:'商品编号',
						field:'commodityId',
						width:100,
						hidden: false
				    },{
						title:'商品名称',
						field:'commodityName',
						width:100,
						sortable: true
					},{
						title:'规格型号',
						field:'commodityType',
						width:100
					},{
						title:'商品分类',
						field:'categoryName',
						width:100,
					},{
						title:'计量单位',
						field:'unitName',
						width:100,
					},{
						title:'普通售价',
						field:'salePrice',
						width:100,
					},{
						title:'初级会员售价',
						field:'vip1Price',
						width:100,
					},{
						title:'中级会员售价',
						field:'vip2Price',
						width:100,
					},{
						title:'高级会员售价',
						field:'vip3Price',
						width:100,
					},{
						title:'备注',
						field:'remark',
						width:300
					}
				]],
				
				
			});
			
			
			/**
			 * 表单提交按钮
			 */
			$('#saveButton').click(function(){
				if($('#addForm').form('validate')){
					
					$.messager.confirm('提示信息' , '确认入库后订单将无法修改，是否确认入库？' , function(result){
						if(result) {
							var arr = $('#supplierTable').datagrid('getSelections');
							var ids = '';
							/* for(var i=0; i<arr.length; i++) {
								ids += arr[i].purchaseId + ',';
							}
							ids = ids.substring(0, ids.length-1); */
							ids += arr[0].purchaseId;
							$.ajax({
								type: 'post',
								url: 'inStockAction_purchase',
								cache: false,
								data: $('#addForm').serialize() + '&ids=' + ids + '&inStockgoods=' + JSON.stringify($('#detailGrid').datagrid('getRows')),
								dataType: 'json',
								success: function(result) {
									$('#addDialog').dialog('close');
									if(result.success){
										//1.刷新数据表格
										$('#supplierTable').datagrid('reload');
										//2.给出提示信息
										$.messager.show ({
											title: "ok!",
											msg: result.message
										});
										//3.清楚数据表格勾选
										$('#supplierTable').datagrid('clearSelections');
										$('#addForm').form('reset');
										$('#supplierTable').datagrid('reload');
										$('#detailGrid').datagrid('loadData',{total:0,rows:[]});
										
									} else {
										$.messager.show ({
											title: "fail!",
											msg: result.message
										});
									}
								},
							});
							
						} else {
							return;
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
			
			/**
			 * 搜索按钮
			 */
			$('#searchButton').click(function() {
				$('#supplierTable').datagrid('load', serializeForm($('#commoditySearch')));
				$('#supplierTable').datagrid('clearSelections');
				$('#detailGrid').datagrid('loadData',{total:0,rows:[]});
			});
			
			/**
			 * 清空按钮
			 */
			$('#clearButton').click(function() {
				$('#commoditySearch').form('reset');
			});
			
			/**
			 * 计量单位下拉菜单
			 */
			$('#unitCombobox').combobox({
				url:'commodityAction_getUnitList',
				editable:false,
			    valueField:'unitId',
			    textField:'unitName',
			});
			
			/**
			 * 设置datebox默认时间
			 */
			$('#beginDate').datebox({
				formatter:myformatter,
				parser:myparser,
				editable:false,
			    required:false,
			    missingMessage:'必须填写日期！'
			});
			/**
			 * 设置datebox默认时间
			 */
			$('#endDate').datebox({
				formatter:myformatter,
				parser:myparser,
				editable:false,
			    required:false,
			    missingMessage:'必须填写日期！'
			});
			
			/**
			 * 入库时间框
			 */
			$('#createDate').datetimebox({    
			    editable: false,   
			    required: true,   
			    missingMessage: '请填写入库时间',
			    showSeconds: true,   
			}); 
		});
		//编辑仓库状态
		var editIndex = undefined;
		//详单表格点击事件
		function onClickCell(index,field,value){
			if(field == 'storageId' & editIndex == undefined) {
				editIndex = index;
				$(this).datagrid('beginEdit', index);
				var ed = $(this).datagrid('getEditor', {index:index,field:field});
				$(ed.target).focus();
			} else {
				return;
			}
			
		}
		//详单保存按钮
		function saveType(target) {
			var index = getRowIndex(target);
			if ($('#detailGrid').datagrid('validateRow', editIndex) & editIndex == index){
				var ed = $('#detailGrid').datagrid('getEditor', {index:editIndex,field:'storageId'});
			 	var storageName = $(ed.target).combobox('getText');
                $('#detailGrid').datagrid('getRows')[editIndex]['storageName'] = storageName;
				$('#detailGrid').datagrid('endEdit', editIndex);
				editIndex = undefined;
				
				
			} else {
				return;
			}
			
			
		}
		//详单取消按钮
		function cancelType(target) {
			var index = getRowIndex(target);
			if ($('#detailGrid').datagrid('validateRow', editIndex) && editIndex == index){
				$('#detailGrid').datagrid('cancelEdit', editIndex);
				editIndex = undefined;
			} else {
				return;
			}
		}
		//获取当前行
		function getRowIndex(target){
			var tr = $(target).closest('tr.datagrid-row');
			return parseInt(tr.attr("datagrid-row-index"));
		}
		
		//时间格式化
		function myformatter(date){
			var y = date.getFullYear();
			var m = date.getMonth()+1;
			var d = date.getDate();
			return y+'-'+(m<10?('0'+m):m)+'-'+(d<10?('0'+d):d);
		}
		//时间解析
		function myparser(s){
			if (!s) return new Date();
			var ss = (s.split('-'));
			var y = parseInt(ss[0],10);
			var m = parseInt(ss[1],10);
			var d = parseInt(ss[2],10);
			if (!isNaN(y) && !isNaN(m) && !isNaN(d)){
				return new Date(y,m-1,d);
			} else {
				return new Date();
			}
		}
		
		
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
		<div region="north" title="库存查询" collapsed=false style="height:80px;padding:10px">
			<form id="commoditySearch">
				商品名称：<input name="commodityName" class="easyui-textbox"/>&nbsp;
				<a id="searchButton" class="easyui-linkbutton" data-options="iconCls:'icon-search'">查询</a>
				<a id="clearButton" class="easyui-linkbutton" data-options="iconCls:'icon-cancel'">清空</a>
			</form>
		</div>
		<div region="center" title="库存报警">
			<table id="supplierTable"></table>
		</div>
		<div region="south" title="商品详细信息" collapsed=false style="height:40%">
			<table id="detailGrid"></table>
		</div>
	</div>
	<div id="addDialog" title="确认入库时间" modal=true class="easyui-dialog"
		closed=true style="width:350px;padding:30px;">
		<form id="addForm" method="post">
			<div style="margin:10px;text-align:center">
				设置入库时间：<input id="createDate" name="createDate" />
			</div>
			<div style="margin:10px;text-align:center">
				<a id="saveButton" class="easyui-linkbutton" iconCls="icon-save" style="margin-right:10px">入库</a>
				<a id="cancelButton" class="easyui-linkbutton" iconCls="icon-cancel" style="margin-left:10px">取消</a>
			</div>
			
		</form>
	</div>
</body>
</html>
