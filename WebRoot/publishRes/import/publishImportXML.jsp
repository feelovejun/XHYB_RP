<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/appframe/common.jsp" %>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
	<title>编辑资源</title>
	<script type="text/javascript" src="${path}/appframe/main/js/libs/bootstrap-rating-input.min.js"></script>
	<link rel="stylesheet" href="${path}/appframe/plugin/zTree/css/zTreeStyle/zTreeStyle.css"/>
	<script type="text/javascript" src="${path}/appframe/plugin/zTree/js/jquery.ztree.all-3.5.js"></script>
	<style>
		/* 该功能保证批次目录下的资源目录显示的也是文件夹图标，而不是文件图标 */
		ul.ztree li span.button.ico_docu{
			margin-right:2px; 
			margin-right:2px; 
			background-position: -147px 0; 
			vertical-align:top; 
			*vertical-align:middle
		}

	</style>
	<script type="text/javascript">
		var setting = {  
            data: {
        		simpleData: {
        			enable: true,
        			idKey: "id",
        			pIdKey: "pId",
        			rootPId: 0,
        		}
        	},
			check: {
				enable: true,
				chkStyle: "checkbox"
			}
        }; 
		function save(){
			var paths="";
			var nodes=zTree.getCheckedNodes(true);
			for(var i=1;i<nodes.length;i++){//不要根节点
				var nodePath = nodes[i].path;
				if(nodePath!="" && typeof(nodePath)!="undefined"){
					paths +=nodePath + ",";
				}
			}
			if(paths==""){
				top.layer.msg('请选择需要导入的批次！');
				return;
			}
			
			$.post("${path}/publishRes/import/saveResByXml.action",
				{
				paths: encodeURI(paths),
				remark: $('#remark').val(),
				repeatType: $('input:radio[name="repeatType"]:checked').val(),
				publishType: $('#publishType').val()
				},
				function(data){
					if(data=='SUCCESS'){
						top.layer.msg('文件上传成功。数据正在导入中，请稍后！');
						top.index_frame.work_main.freshDataTable('data_div');
						top.layer.closeAll("iframe"); //关闭信息框
					}else{
						top.layer.msg('文件上传出错。请检查导入目录的文件！');
					}
		    });
		}
	          
        var zTree;  
        var treeNodes;  
	          
        $(function(){  
            $.ajax({  
                async : false,  
                cache:false,  
                type: 'POST',  
                dataType : "json",  
                url: "${path}/publishRes/import/getXmlJson.action",//请求的action路径  
                error: function () {//请求失败处理函数  
                    notice("警告","获取标准资源目录下的批次&资源信息出错，请检查系统参数中的标准资源批量导入路径配置是否正确！","3");
                },  
                success:function(data){ //请求成功后处理函数。    
                    treeNodes = data;   //把后台封装好的简单Json格式赋给treeNodes  
                }  
            });  
            zTree = $.fn.zTree.init($("#tree"), setting, treeNodes);
           // zTree = $("#tree").zTree(setting, treeNodes);  
        }); 
	</script>
</head>
<body>
<div class="form-wrap">
	<input type="hidden" id="publishType" name="publishType" value="${param.publishType}"/>
	<form action="#" id="coreData" class="form-horizontal">
		<div class="form-group">
			<label class="col-sm-3 control-label text-right">文件目录：<span class="required">*</span></label>
			<div class="col-sm-9">
			<div style="overflow-y:auto; width:100%; height:100%;">
				<ul id="tree" class="ztree form-wrap"></ul>
			</div>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-3 control-label text-right">重复策略：</label>
			<div class="col-sm-9">
				<label class="radio-inline">
					<input type="radio" name="repeatType" value="3" checked="checked"/> 忽略
				</label>
				<label class="radio-inline">
					<input type="radio" name="repeatType" value="1" /> 新版本
				</label>
				<label class="radio-inline">
					<input type="radio" name="repeatType" value="4" /> 元数据覆盖(文件增量)
				</label>
			</div>
		</div>
		<div class="form-group">
			<label class="col-sm-3 control-label text-right"></label>
			<div class="col-sm-9">
				<label class="radio-inline">
					<input type="radio" name="repeatType" value="2"/> 元数据增量(文件增量)
				</label>
			</div>
		</div>
<!-- 		<div class="form-group"> -->
<!-- 			<label class="col-sm-3 control-label text-right">来自加工任务：</label> -->
<!-- 			<div class="col-sm-9"> -->
<!-- 				<label class="radio-inline"> -->
<!-- 					<input type="radio" name="processTask" value="1"/> 是 -->
<!-- 				</label> -->
<!-- 				<label class="radio-inline"> -->
<!-- 					<input type="radio" name="processTask" value="0" checked="checked"/> 否 -->
<!-- 				</label> -->
<!-- 			</div> -->
<!-- 		</div> -->
<!-- 		<div class="form-group"> -->
<!-- 			<label class="col-sm-3 control-label text-right">重复关联策略：</label> -->
<!-- 			<div class="col-sm-9"> -->
<!-- 				<label class="checkbox-inline"> -->
<!-- 					<input type="checkbox" name="repeatRelevanceType" value="1" checked="checked"/> 自动关联 -->
<!-- 				</label> -->
<!-- 			</div> -->
<!-- 		</div> -->
		<div class="form-group">
			<label class="col-sm-3 control-label text-right">备注：</label>
			<div class="col-sm-9">
				<textarea rows="2" class="form-control" name="remark" id="remark"></textarea>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-offset-3 col-sm-9">
               	<input id="tijiao" type="button" value="提交" class="btn btn-primary" onclick="save();"/> 
               	<input class="btn btn-primary" type="button" value="关闭 " onclick="parent.parent.layer.closeAll();"/>
            </div>
        </div>
	</form>
</div>
</body>
</html>