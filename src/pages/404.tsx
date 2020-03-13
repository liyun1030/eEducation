import React from 'react';
import {t} from '../i18n';

import './404.scss';
import { useHistory } from 'react-router-dom';

// TODO: config your home page
// 这里可以配置404页面的返回按钮
const url = process.env.REACT_APP_AGORA_EDU_MAIN_LINK as string

const BasicLayout: React.FC<any> = ({children}) => {
  return (
    <div className="main-layout-container">
      {children}
    </div>
  )
}

export const PageNotFound: React.FC<any> = () => {

  const history = useHistory();

  return (
    <BasicLayout>
      <div className="layout-content">
        <h1>404</h1>
        <h2>{t('error.not_found')}</h2>
        <a style={{"cursor": "pointer"}} href={url}>{t('return.home')}</a>
        {/* <a style={{"cursor": "pointer"}} onClick={() => {
            history.push('/');
        }}>{t('return.home')}</a> */}
      </div>
    </BasicLayout>
  )
}