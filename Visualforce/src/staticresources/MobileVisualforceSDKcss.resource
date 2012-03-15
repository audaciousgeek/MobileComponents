body {
  visibility: hidden;
}

.ui-page, .ui-bar-c {
    background-image: none;
    background: none;
}

.ui-header {
    height: 35px;
    padding: 10px 16px;
    line-height: 35px;
    background-image: -webkit-gradient(linear, 0 0, 0 100%, color-stop(0, rgba(255, 255, 255, 0.5)), color-stop(0.85, rgba(255, 255, 255, 0)), color-stop(1, transparent));
}

.ui-footer {
    background-image: -webkit-gradient(linear, 0 100%, 0 0, color-stop(0, rgba(255, 255, 255, 0.5)), color-stop(0.85, rgba(255, 255, 255, 0)), color-stop(1, transparent));
}

.ui-panel-right .ui-header, .ui-panel-right .ui-footer {
	background: #236FBD url('/img/touch/headerCloud.png') no-repeat;
    background-position: 90% bottom;
    border-top-left-radius: 3px;
    border-top-right-radius: 3px;
    -webkit-box-shadow: inset 0 1px 0 rgba(255,255,255,.3);
    white-space: nowrap;
}

.ui-listview {
    text-shadow: none;
}

.ui-listview-filter {
    padding: 5px 0;
}

.ui-listview li {
    padding: 7px 10px 10px; 
    color: #CDCDCD; 
    border-bottom: 1px solid rgba(0, 0, 0, 0.5);
    border-top: 1px solid rgba(225, 225, 225, 0.2);
}

.ui-listview li[data-role="list-divider"] {
    padding: 5px 10px;
    color: #1797C0;
    background-color: #333;
    border: none;
}

.layout {
    background: white;
    margin: -15px;
    padding: 15px;
}

.layoutSection fieldSet dl {
    padding: 12px 0;
    border-bottom: 1px solid #C9CCCD;
}

.layoutSection .ui-grid-a {
    display: -webkit-box;
    vertical-align: baseline;
}

.layoutSection .ui-block-a, .layoutSection .ui-block-b {
    float: none;
}

.ui-block-a {
    margin-right: 10px;
}

.layoutSection .fieldLbl {
	color: #8F989B;
	font-size: 12px;
	font-weight: bold;
	line-height: 12px;
	margin-bottom: 4px;
}

.layoutSection .fieldVal {
	width: 90%;
	font-size: 15px;
	color: #2A2A2A;
	line-height: 14px;
	-webkit-margin-start: 0px;
	margin-start: 0px;
	min-height: 20px;
}

.layoutSection .fieldVal a {
    color: #1679C9;
    text-decoration: none;
}