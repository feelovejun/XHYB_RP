<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/appframe/common.jsp"%>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>列表</title>
	<link rel="stylesheet" href="${path}/appframe/plugin/zTree/css/zTreeStyle/zTreeStyle.css"/>
	<script type="text/javascript" src="${path}/appframe/plugin/zTree/js/jquery.ztree.all-3.5.js"></script>
	<script type="text/javascript" src="${path}/system/book/bookUtil.js"></script>
	<script type="text/javascript">
    var zTree;
    var demoIframe;
    var zNodes;
    function addHoverDom(treeId, treeNode) {
        var sObj = $("#" + treeNode.tId + "_span");
        var zTree = $.fn.zTree.getZTreeObj("tree");
        
        if ($("#importBtn_"+treeNode.tId).length==0&&treeNode.level==1){
			var importStr = "<sec:authorize url='/system/book/importExcel.jsp'><span class='button import' id='importBtn_" + treeNode.tId
			+ "' title='导入' onfocus='this.blur();'></span></sec:authorize>";
			sObj.after(importStr);
			var importBtn = $("#importBtn_" + treeNode.tId);
			if (importBtn)
				importBtn.bind("click",function(){
					var xpath = treeNode.xpath + "," + treeNode.code;
					$.openWindow("system/dataManagement/classification/importClassicExcel.jsp?moudleName=knowledge&pid="
							+ treeNode.nodeId + "&id="+treeNode.objectId+"&xpath="+xpath,'导入分类体系',450,200);
				});
        }
        
        if ($("#removeBtn_"+treeNode.tId).length==0&&treeNode.level>0){
        	var removeStr = "<sec:authorize url='/system/dataManagement/classification/knowledge/deleteNode.action'><span class='button remove' id='removeBtn_"
        		+ treeNode.tId + "' title='删除节点' onfocus='this.blur();'></span></sec:authorize>";
        	sObj.after(removeStr);
            var del = $("#removeBtn_"+treeNode.tId);
            if (del) del.bind("click", function(){
            	$.confirm('确定要删除所选数据吗？', function(){
	            	$.post("knowledge/deleteNode.action",
	                		{
	                			objectId:treeNode.objectId,
	                			domainType:"domainType=1"
	                		},
	                		function(data){
	        		        	zTree.removeNode(treeNode);
	                		} 
	                );
            	});
            });
        }
        
        if ($("#addBtn_"+treeNode.tId).length==0){
			var addStr = "<sec:authorize url='/system/book/knowledge/getSelectValues.action'><span class='button add' id='addBtn_"
				+ treeNode.tId + "' title='添加节点' onfocus='this.blur();'></span></sec:authorize>";
			sObj.after(addStr);
	        var add = $("#addBtn_"+treeNode.tId);
	        if (add) add.bind("click", function(){
	        	$("#operation").val("add");
	        	var nodeType =  getNodeType(treeNode);
	        	$("#fromId").val(treeNode.objectId);
				$("#nodeType").val(nodeType);
				$("#nodeParentId").val(treeNode.nodeId);
				var selectDiv = $("#selectDiv");
				selectDiv.empty();
				if(treeNode.nodeType==3||treeNode.nodeType==6||treeNode.nodeType==5){
					$("#versionText").modal('show');
				}else{
					$.post("getSelectValues.action", {
						nodeType : nodeType,
						code : treeNode.code
					}, function(data) {
						var jsonArray = eval("(" + data + ")");
						if (!jsonArray)
							return;
						createSelectList(jsonArray, null);
						$('#myModal').modal('show');
					});
				}
				return false;
	        });
        }
        
        if ($("#editBtn_"+treeNode.tId).length==0&&treeNode.level>0){
			var editStr = "<sec:authorize url='/system/book/knowledge/getSelectValues.action'><span class='button edit' id='editBtn_"
				+ treeNode.tId + "' title='编辑节点' onfocus='this.blur();'></span></sec:authorize>";
			sObj.after(editStr);
			var edit = $("#editBtn_" + treeNode.tId);
			if (edit)
				edit.bind("click",function() {
					$("#operation").val("edit");
					$("#fromId").val(treeNode.getParentNode().objectId);
					$("#nodeParentId").val(treeNode.pid);
					$("#nodeNumber").val(treeNode.nodeId);
					$("#nodeType").val(treeNode.nodeType);
					var selectDiv = $("#selectDiv");
					selectDiv.empty();
					if(treeNode.nodeType==6||treeNode.nodeType==5){
						$("#versionText").modal('show');
					}else{
						$.post("getSelectValues.action", {
							nodeType : treeNode.nodeType,
							code : treeNode.getParentNode().code
						}, function(data) {
							var jsonArray = eval("(" + data + ")");
							if (!jsonArray)
								return;
							createSelectList(jsonArray, treeNode.code);
							$('#myModal').modal('show');
						});
					}
					return false;
				});
        }
        
    };

    function removeHoverDom(treeId, treeNode) {
        $("#removeBtn_"+treeNode.tId).unbind().remove();
        $("#addBtn_"+treeNode.tId).unbind().remove();
        $("#editBtn_"+treeNode.tId).unbind().remove();
        $("#importBtn_"+treeNode.tId).unbind().remove();
    };

    var setting = {
        view: {
            addHoverDom: addHoverDom,
            removeHoverDom: removeHoverDom,
            dblClickExpand: false,
            showLine: true,
            selectedMulti: false
        },
        data: {
            simpleData: {
                enable:true,
                idKey: "nodeId",
                pIdKey: "pid",
                rootPId: "0"
            }
        }
    };

    $(document).ready(function(){
        var t = $("#tree");
		$.get("listClassification.action?moudleName=ZS",
			function(data) {
				var books = eval("("+data+")");
				zNodes = books.domains;
				for(var i=0;i<zNodes.length;i++){
					zNodes[i]["name"] = zNodes[i].label;
				}
				t = $.fn.zTree.init(t, setting, zNodes);
				var root = t.getNodes()[0];
				if(root){
					t.expandNode(root,true,false,true);
				}				
			    demoIframe = $("#testIframe");
			    demoIframe.bind("load", loadReady);
		});
    });

    function loadReady() {
        var bodyH = demoIframe.contents().find("body").get(0).scrollHeight,
                htmlH = demoIframe.contents().find("html").get(0).scrollHeight,
                maxH = Math.max(bodyH, htmlH), minH = Math.min(bodyH, htmlH),
                h = demoIframe.height() >= maxH ? minH:maxH ;
        if (h < 400) h = 400;
        demoIframe.height(h);
    }

	//生成单个节点json数据
	function getNodeJson(node) {
		var t = $.fn.zTree.getZTreeObj("tree");
		var pNode = t.getNodesByParam("nodeId",node.pid)[0];
		var xpath = "";
		if(pNode.xpath)
			xpath = pNode.xpath + "," + pNode.code;
		var books = {
			"@type" : "domainList",
			"domainType" : 0
		};
		var domains = [];
		var book = {
			"label" : node.name,
			"nodeId" : node.nodeId,
			"nodeType" : node.nodeType,
			"pid" : node.pid,
			"code" : node.code,
			"level" : node.level,
			"xpath" : xpath
		};
		if (node.objectId)
			book["objectId"] = node.objectId;
		if (node.xpath)
			book["xpath"] = node.xpath;
		if (node.pcode)
			book["pcode"] = node.pcode;
		if (node.domainType===1)
			book["domainType"] = node.domainType;		
		if (node.broaders)
			book["broaders"] = node.broaders;
		if (node.broaderNames)
			book["broaderNames"] = node.broaderNames;		
		domains.push(book);
		var domainStr = JSON.stringify(domains);
		books["domains"] = domainStr;
		return books;
	}
	
	function importExcel(){
		$.openWindow("system/dataManagement/classification/importClassicExcel.jsp?moudleName=knowledge",'导入分类体系',450,200);
	}
	
	//保存新节点
	function saveNode() {
		var t = $.fn.zTree.getZTreeObj("tree");
		var node = {};
		var nodeType = $("#nodeType").val();
		//修改节点
		if($("#operation").val()=='edit'){
			//选择的节点
			node = t.getNodesByParam("nodeId", $("#nodeNumber").val())[0];
			if(nodeType!=6&&nodeType!=5){
				var text = $("input:radio[name='nodeLabel']:checked").parent().text();
				var check = t.getNodesByParam("name", text, node.getParentNode());
				if(node.name!=text&&check.length>0){
					alert("[" + check[0].name + "]节点已存在，请选择其他节点");
					return;
				}
				node.name = text;
				node.code = $("input:radio[name='nodeLabel']:checked").val();
			}else{
				//输入的节点
				if($("#labelName").val().length==0){
					alert("请输入节点名称");
					return;
				}				
				node.name = $("#labelName").val();
			}
		}else{
			//添加节点
			var parentNode = t.getNodesByParam("nodeId", $("#nodeParentId").val())[0];
			//选择的节点
			if(nodeType!=6&&nodeType!=5){
				node = {
					name : $("input:radio[name='nodeLabel']:checked").parent().text(),
					code : $("input:radio[name='nodeLabel']:checked").val(),
					nodeType : $("#nodeType").val(),
					pid : $("#nodeParentId").val(),
					nodeId : _getRandomString(8),
					level: parentNode.level + 1,
					pcode: parentNode.code,
					domainType: 1,
					broaders: [parentNode.objectId],
					broaderNames:getBroaderNames(parentNode,$("input:radio[name='nodeLabel']:checked").parent().text())
				};
				if(parentNode.xpath)
					node.xpath = parentNode.xpath + "," + parentNode.code;
				else
					node.xpath = parentNode.code;
				if(!$("input:radio[name='nodeLabel']:checked").val()){
					alert("请选择节点信息");
					return;
				}
				var check = t.getNodesByParam("name", node.name, parentNode);
				if (check.length > 0) {
					alert("[" + node.name + "]节点已存在，请选择其他节点");
					return;
				}
			}else{
				//输入的节点
				if($("#labelName").val().length==0){
					alert("请输入节点名称");
					return;
				}				
				node = {
					name : $("#labelName").val(),
					code : _getRandomString(8),
					nodeType : nodeType,
					pid : $("#nodeParentId").val(),
					nodeId : _getRandomString(8),
					level: parentNode.level + 2,
					xpath: parentNode.xpath + "," + parentNode.code,
					pcode: parentNode.code,
					domainType: 1,
					broaderNames: getBroaderNames(parentNode,$("#labelName").val()),
					broaders: [parentNode.objectId]
				};
			}
		}
		//提交修改
		var books = getNodeJson(node);
		$.post("createClassification.action?fromId=" + $("#fromId").val()+"&type=classification", books,
				function(data) {
					var books = eval("(" + data + ")");
					if (books.state != 0) {
						alert("保存失败");
						return;
					}
					if($("#operation").val()=='edit'){
						var treeNode = t.getNodesByParam("nodeId", $(
								"#nodeNumber").val())[0];
						if(nodeType!=6&&nodeType!=5){
							treeNode.name = $("input:radio[name='nodeLabel']:checked").parent().text();
							$('#myModal').modal('hide');
						}
						else{
							treeNode.name = $("#labelName").val();
							$("#versionText").modal('hide');
						}
						t.updateNode(treeNode);
					}else{
						var treeNode = t.getNodesByParam("nodeId", $(
									"#nodeParentId").val())[0];
						node.objectId = books.objectId;
						newNode = t.addNodes(treeNode, node);
						if(nodeType!=6&&nodeType!=5)
							$('#myModal').modal('hide');
						else{
							$("#versionText").modal('hide');
							if(treeNode.nodeType==6){
								treeNode.nodeType = 5;
								treeNode.domainType = 1;
								var books = getNodeJson(treeNode);
						        $.post("changeNodeType.action",books,
							        	function(data){
//							        		alert(data);
								});
							}
						}
					}
				});
	}
	
	//创建列表
	function createSelectList(jsonArray, code) {
		for (var i = 0; i < jsonArray.length; i += 2) {
			var div = $("<div class='radio form-wrap'></div>");
			div.appendTo(selectDiv);
			var label = $("<label class='control-label col-xs-6'></label>");
			label.text(jsonArray[i].nodeValue);
			label.appendTo(div);
			var radio = $("<input type='radio' name='nodeLabel'/>");
			radio.val(jsonArray[i].nodeKey);
			radio.appendTo(label);
			if(jsonArray[i + 1]){
				var label2 = $("<label class='control-label col-xs-6'></label>");
				label2.text(jsonArray[i + 1].nodeValue);
				label2.appendTo(div);
				var radio2 = $("<input type='radio' name='nodeLabel'/>");
				radio2.val(jsonArray[i + 1].nodeKey);
				radio2.appendTo(label2);
			}
		}
		if (code) {
			$("input[name=nodeLabel][value=" + code + "]").attr("checked",true);
		}
	}
	
	function getNodeType(treeNode){
		var nodeType = 0;
		if(treeNode.nodeType==7){
    		nodeType = 1;
    	}else if(treeNode.nodeType==1){
    		nodeType = 3;
    	}else if(treeNode.nodeType==3 || treeNode.nodeType==5){
			nodeType = 6;
    	}else if(treeNode.nodeType==6){
    		nodeType = 6;
    	}
    	return nodeType;
	}
	
	function getBroaderNames(parentNode,name){
		var names = [];
		names.push(name);
		while(parentNode){
			if(parentNode.nodeType==0){
				names.push(parentNode.label);
				break;
			}else{
				names.push(parentNode.label);
			}
			parentNode = parentNode.getParentNode();
		}
		return names.reverse().join(",");
	}
	
	function dojob(){
		if(checkJobStatus()=="0"){
			$.confirm('优化分类树会影响系统性能，仅在导入新的教材版本后执行', function(){
				$.get("${path}/system/book/dojob.action?type=1",function(data){
					
				});
			});
		}else{
			$.alert("正在建立级联及相关关系，请稍后！");
		}
	}
	</script>	
</head>
<body>
	<div id="fakeFrame" class="container-fluid by-frame-wrap " style="height: 100%;">
	    <ul class="page-breadcrumb breadcrumb">
	        <li>
	            <a href="###">分类体系管理</a>
	            <i class="fa fa-angle-right"></i>
	        </li>
	        <li>
	            <a href="###">资源模块</a>
	            <i class="fa fa-angle-right"></i>
	        </li>
	        <li>
	            <a href="###">知识点资源</a>
	            <i class="fa fa-angle-right"></i>
	        </li>	        
	        <li style="float:right;">
	        	<sec:authorize url="/system/dataManagement/classification/importExcel.jsp">
	        		<span class="glyphicon glyphicon-import"></span>
	        		<a href="###" onclick="importExcel();">批量导入</a>
	        	</sec:authorize>
	        </li>	
	        <li style="float:right;" class="col-xs-2">
	        	<span class="glyphicon glyphicon-refresh"></span>
	        	<a href="###" onclick="dojob();">优化分类树</a>
	        </li>	                
    	</ul>
		<div class="col-sm-5" style="height: 100%;">
			<ul id="tree" class="ztree form-wrap" style="overflow:auto;"></ul>
		</div>
		<div class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" 
			aria-labelledby="mySmallModalLabel" aria-hidden="true" id="myModal">
  			<div class="modal-dialog modal-sm">
  				<div class="modal-content">
  					<div class="form-group" id="selectDiv">
    				</div>
					<div class="form-wrap">
						<button class="btn btn-primary col-xs-offset-1" onclick="saveNode()">确定</button>															
					</div>
					<label class=""></label>
				</div>
  			</div>
		</div>
		<div class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" 
			aria-labelledby="mySmallModalLabel" aria-hidden="true" id="versionText">
  			<div class="modal-dialog modal-sm">
  				<div class="modal-content">
  					<div class="form-wrap">
  						<div class="col-xs-9">
							<input id="labelName" type="text" class="form-control" placeholder="输入名称"/>
						</div>						
    				</div>
					<div class="form-group">
						<button class="btn btn-primary" onclick="saveNode()">确定</button>															
					</div>
				</div>
  			</div>
		</div>		
	</div>
	<input id="nodeNumber" type="hidden"/>
	<input id="nodeType" type="hidden"/>
	<input id="nodeParentId" type="hidden"/>
	<input id="fromId" type="hidden"/>
	<input id="operation" type="hidden"/>
</body>
</html>