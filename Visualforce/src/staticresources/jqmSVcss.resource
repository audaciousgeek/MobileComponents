body {
  visibility: hidden;
}

.ui-panel {
  -moz-box-shadow: 0 0 12px rgba(0,0,0,.6);
  -webkit-box-shadow: 0 0 12px rgba(0,0,0,.6);
  box-shadow: 0 0 12px rgba(0,0,0,.6);
}

div[data-id="main"] {
  z-index: 9999;
}

.ui-mobile body {
  visibility: visible;
}

.ui-mobile .ui-panel-left {
  min-width: 250px; max-width: 25%;
  height: 100%;
  position: relative;
  overflow: hidden;
}

.ui-mobile .ui-panel-right {
  height: 100%;
  position: relative;
  overflow: hidden;
  -webkit-box-flex: 1;
  -webkit-box-shadow: -10px -20px 20px rgba(25, 25, 25, 0.7);
}

.ui-mobile .ui-crumbs {
  max-width: 25%;
}

.ui-mobile .splitview .ui-splitview-hidden {
  display:none;
}

@media (min-width:480px) {
  .ui-mobile .splitview {
    margin: 0; height: 100%;
    display:-webkit-box;
    overflow: hidden;
  }

  .ui-mobile .splitview .ui-page {
    overflow: hidden;
    position: relative;
    width: auto;
    height: 100%;
    display: -webkit-box;
    -webkit-box-orient: vertical;
    -webkit-box-pack: justify;
  }

  .ui-mobile .splitview .ui-page .ui-content {
    overflow:hidden; overflow-y: scroll;
    -webkit-overflow-scrolling:touch;
    -webkit-box-flex: 1;
    z-index:1;
  }
}

/************************************************************************************************************
popover css for portrait orientation, modified from 
http://www.cagintranet.com/archive/create-an-ipad-like-dropdown-popover/
************************************************************************************************************/
.ui-mobile .splitview .panel-popover .popover_triangle {left:7px;}
.ui-mobile .splitview .panel-popover {
  color: black;
  display:none;
  font-weight: normal;
  line-height: 1;
  cursor: auto;
  position: absolute;
  top:70px;
  left:10px;
  background-color: white;
  z-index:5000000;
  border: 3px solid black;
  border-radius: 4px;
  -webkit-border-radius: 4px;
  -moz-border-radius: 4px;
  border-radius: 4px;
  -webkit-box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
  -moz-box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
  -webkit-transition: opacity 0.25s linear;
  -moz-transition: opacity 0.25s linear;
  transition: opacity 0.25s linear; 
  overflow-x:visible;
  height:80%;
}

.ui-mobile .splitview .panel-popover > .popover_triangle {
  position: absolute;
  top: -34px;
  font-size: 0px;
  line-height: 0%;
  width: 0px;
  border-top: 16px solid rgba(0,0,0,0);
  border-left: 16px solid rgba(0,0,0,0);
  border-right: 16px solid rgba(0,0,0,0);
  border-bottom: 16px solid black; 
}

.ui-mobile .splitview .panel-popover div[data-role="page"] {
  height: inherit;
  overflow-y:auto;
}

.ui-mobile .splitview .popover-btn {
    min-width: 56px;
    line-height: 22px;
    font-size: 15px;
    font-weight: bold;
    color: #363C40;
    text-shadow: white 0px 1px 1px;
    text-decoration: none;
    text-align: center;
    display: inline-block;
    padding: 7px 12px;
    border: 1px solid #9D9D9D;
    border-radius: 3px;
    -webkit-border-radius: 3px;
    -webkit-box-shadow: inset 0 1px 0 0 #fff;
    position: absolute;
    background-color: #F0F3F4;
    background-image: none;
}

/**********************************************************************************************************
CSS animations for panel resize using new data-width attribute.
**********************************************************************************************************/
